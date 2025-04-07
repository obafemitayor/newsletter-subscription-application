class Subscription < ApplicationRecord
  # Soft delete
  scope :active, -> { where(deleted_at: nil) }

  FETCH_SUBSCRIPTIONS = lambda do |limit:, category_guids: nil, pagination_id: nil, pagination_direction: 'forward'|
    query = active
            .joins(:customer, :category)
            .select(
              'customers.id as customer_id',
              'customers.work_email',
              'customers.first_name',
              'customers.last_name',
              'GROUP_CONCAT(categories.name) as category_names'
            )
            .group(
              'customers.id',
              'customers.work_email',
              'customers.first_name',
              'customers.last_name'
            )

    query = query.where(categories: { guid: category_guids }) if category_guids.present?

    # using cursor-based pagination because it is more efficient and
    # scales better with large data sets than offset-based pagination
    if pagination_id.present?
      query = query.where(
        pagination_direction == 'forward' ? 'customers.id > ?' : 'customers.id < ?',
        pagination_id
      )
    end

    query.order("customers.id #{pagination_direction == 'forward' ? 'ASC' : 'DESC'}")
         .limit(limit)
  end

  scope :fetch_subscriptions, FETCH_SUBSCRIPTIONS

  # Relationships
  belongs_to :customer
  belongs_to :category

  # Validations
  validates :customer_id, uniqueness: { scope: :category_id }

  # Instance methods
  def soft_delete
    update(deleted_at: Time.current)
  end

  def restore
    update(deleted_at: nil)
  end

  def deleted?
    deleted_at.present?
  end
end
