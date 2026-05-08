FactoryBot.define do
  factory :order do
    sequence(:number) { |n| "ORDER-#{n.to_s.rjust(4, '0')}" }
    customer_name { "Smeha Smehason" }
    customer_email { "smeha@smeha.co" }
    shipping_address { "1234567 Market St, San Diego, CA" }
    status { "pending_review" }
    submitted_at { Time.current }
  end
end
