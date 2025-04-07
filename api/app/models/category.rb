class Category < ApplicationRecord
  # Soft delete
  scope :active, -> { where(deleted_at: nil) }

  # Relationships
  has_many :subscriptions, dependent: :destroy
  has_many :customers, through: :subscriptions

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }

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
