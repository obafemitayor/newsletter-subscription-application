FactoryBot.define do
  factory :customer do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    work_email { Faker::Internet.unique.email }
    deleted_at { nil }
  end
end
