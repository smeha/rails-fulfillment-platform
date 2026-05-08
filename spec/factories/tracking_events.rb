FactoryBot.define do
  factory :tracking_event do
    order
    sequence(:external_id) { |n| "tracking-event-#{n}" }
    carrier { "Simulated Carrier" }
    tracking_number { "SIMULATED_CARRIER-0000001001" }
    status { "in_transit" }
    description { "Package is in transit" }
    occurred_at { Time.current }
    raw_payload { {} }
  end
end
