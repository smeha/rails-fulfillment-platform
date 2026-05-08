FactoryBot.define do
  factory :order do
    sequence(:number) { |n| "ORDER-#{n.to_s.rjust(4, '0')}" }
    customer_name { "Smeha Test" }
    customer_email { "smeha@example.com" }
    shipping_address { "1234567 Market St, San Diego, CA 92130" }
    status { "pending_review" }
    submitted_at { Time.current }
  end
end
