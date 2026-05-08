FactoryBot.define do
  factory :product do
    sequence(:sku) { |n| "SKU-#{n.to_s.rjust(4, '0')}" }
    name { "Shipping Box" }
    price_cents { 1299 }
    active { true }
  end
end
