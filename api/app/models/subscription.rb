class Subscription < ApplicationRecord
  # Soft delete
  scope :active, -> { where(deleted_at: nil) }
  
  # Relationships
  belongs_to :customer
  belongs_to :category

  # Validations
  validates :customer_id, presence: true
  validates :category_id, presence: true
  validates :customer_id, uniqueness: { scope: :category_id, message: "already subscribed to this category" }

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
