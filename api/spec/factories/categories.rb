FactoryBot.define do
  factory :category do
    name { Faker::Lorem.unique.word }
    deleted_at { nil }
  end
end
