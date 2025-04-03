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

    def get_subscriptions(category_guids: nil, last_id: nil, limit: 10)
      subscriptions = Subscription.active
                                .joins(:customer, :category)
                                .select('subscriptions.id',
                                      'customers.work_email',
                                      'customers.first_name',
                                      'customers.last_name',
                                      'categories.name as category_name')

      subscriptions = subscriptions.where(categories: { guid: category_guids }) if category_guids.present?
      subscriptions = subscriptions.where('subscriptions.id > ?', last_id) if last_id.present?
      subscriptions = subscriptions.order(:id).limit(limit)
      {
        subscriptions: subscriptions.as_json(except: :id),
        next_cursor: subscriptions.last&.id
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
  end
end
