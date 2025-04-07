# frozen_string_literal: true

class SubscriptionService
  class << self
    def create_subscription(work_email:, first_name:, last_name:, category_guids:)
      return if category_guids.blank?

      ActiveRecord::Base.transaction do
        customer = Customer.find_or_create_by!(work_email: work_email) do |c|
          c.first_name = first_name
          c.last_name = last_name
          c.guid = SecureRandom.uuid
        end
        subscriptions = prepare_subscription_data(customer, category_guids)
        Subscription.insert_all!(subscriptions)
      rescue StandardError
        raise StandardError, I18n.t('services.subscription.errors.create_failed')
      end
    end

    def get_subscriptions(category_guids: nil, pagination_id: nil, pagination_direction: 'forward', limit: 10)
      subscriptions = fetch_subscriptions(
        category_guids: category_guids,
        limit: limit + 1,
        pagination_id: pagination_id,
        pagination_direction: pagination_direction
      ).to_a

      subscription_list = build_subscription_list(subscriptions, limit, pagination_direction)
      formatted_subscription_list = format_subscription_list(subscription_list)
      {
        subscriptions: formatted_subscription_list.as_json(except: [:id, :customer_id]),
        previous_cursor: formatted_subscription_list.first&.customer_id,
        next_cursor: formatted_subscription_list.last&.customer_id,
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

    def fetch_subscriptions(limit:, category_guids: nil, pagination_id: nil, pagination_direction: 'forward')
      subscriptions = Subscription.fetch_subscriptions(
        limit: limit,
        category_guids: category_guids,
        pagination_id: pagination_id,
        pagination_direction: pagination_direction
      )
      pagination_direction == 'backward' ? subscriptions.reverse : subscriptions
    end

    def build_subscription_list(subscriptions, limit, pagination_direction)
      return subscriptions.take(limit) if pagination_direction == 'forward'
      return subscriptions.drop(1).take(limit) if subscriptions.size > limit

      subscriptions.take(limit)
    end

    def format_subscription_list(subscription_list)
      subscription_list.map do |subscription|
        subscription.tap do |s|
          s.category_names = s.category_names&.split(',') || []
        end
      end
    end
  end
end
