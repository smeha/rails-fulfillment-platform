FactoryBot.define do
  factory :internal_user do
    name { "Smeha Smehason" }
    sequence(:email) { |n| "internal#{n}@example.com" }
    password { "password123" }
    active { true }
  end
end
