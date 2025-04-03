class Customer < ApplicationRecord
  # Soft delete
  scope :active, -> { where(deleted_at: nil) }
  
  # Relationships
  has_many :subscriptions, dependent: :destroy
  has_many :categories, through: :subscriptions

  # Validations
  validates :work_email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true

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
