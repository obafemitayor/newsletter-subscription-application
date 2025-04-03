FactoryBot.define do
  factory :category do
    guid { SecureRandom.uuid }
    name { Faker::Lorem.unique.word }
    deleted_at { nil }
  end
end
