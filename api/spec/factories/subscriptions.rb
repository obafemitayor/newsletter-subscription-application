FactoryBot.define do
  factory :subscription do
    association :customer
    association :category
    guid { SecureRandom.uuid }
    deleted_at { nil }
  end
end
