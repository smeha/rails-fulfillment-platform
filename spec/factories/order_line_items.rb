FactoryBot.define do
  factory :order_line_item do
    order
    product
    quantity { 1 }
  end
end
