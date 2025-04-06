# frozen_string_literal: true

class SubscriptionService
  class << self
    def create_subscription(work_email:, first_name:, last_name:, category_guids:)
      return if category_guids.blank?

      ActiveRecord::Base.transaction do
        customer = Customer.find_or_create_by!(work_email:) do |c|
          c.first_name = first_name
          c.last_name = last_name
          c.guid = SecureRandom.uuid
        end
        subscriptions = prepare_subscription_data(customer, category_guids)
        Subscription.insert_all!(subscriptions)
      end
    end

    def get_subscriptions(category_guids: nil, pagination_id: nil, pagination_direction: 'forward', limit: 10)
      data_size = limit + 1
      subscriptions = fetch_subscriptions_from_db(
        category_guids: category_guids,
        limit: data_size,
        pagination_id: pagination_id,
        pagination_direction: pagination_direction
      )
      subscription_list = build_subscription_list(subscriptions, limit, pagination_direction)

      {
        subscriptions: subscription_list.as_json(except: :id),
        previous_cursor: subscription_list.first&.id,
        next_cursor: subscription_list.last&.id,
        has_more: subscriptions.size > limit
      }
    end

    private

    def get_unsubscribed_category_ids(customer, category_guids)
      subscribed_guids = customer.subscriptions.joins(:category).pluck('categories.guid')
      unsubscribed_category_guids = category_guids - subscribed_guids
      Category.where(guid: unsubscribed_category_guids).pluck(:id)
    end

    def prepare_subscription_data(customer, category_guids)
      unsubscribed_category_ids = get_unsubscribed_category_ids(customer, category_guids)
      # This is a very rare edge case but adding it just to be safe.
      raise ActiveRecord::Rollback if unsubscribed_category_ids.empty?

      unsubscribed_category_ids.map do |category_id|
        {
          customer_id: customer.id,
          category_id: category_id,
          guid: SecureRandom.uuid,
          created_at: Time.current,
          updated_at: Time.current
        }
      end
    end

    def fetch_subscriptions_from_db(category_guids: nil, limit:, pagination_id: nil, pagination_direction: 'forward')
      subscriptions = Subscription.active
      .joins(:customer, :category)
      .select('subscriptions.id',
            'customers.work_email',
            'customers.first_name',
            'customers.last_name',
            'categories.name as category_name')

      subscriptions = subscriptions.where(categories: { guid: category_guids }) if category_guids.present?
      subscriptions = subscriptions.where(pagination_direction == 'forward' ? 'subscriptions.id > ?' : 'subscriptions.id < ?', pagination_id) if pagination_id.present?
      subscriptions = subscriptions.order(id: pagination_direction == 'forward' ? :asc : :desc).limit(limit)

      Rails.logger.info("Subscriptions: #{subscriptions.to_json.to_s}")

      # Reverse the order when pagination direction is backward to ensure the value of previous cursor is correct
      pagination_direction == 'backward' ? subscriptions.reverse : subscriptions
    end

    def build_subscription_list(subscriptions, limit, pagination_direction)
      return subscriptions.take(limit) if pagination_direction == 'forward'
      return subscriptions.drop(1).take(limit) if subscriptions.size > limit
      subscriptions.take(limit)
    end

  end
end
