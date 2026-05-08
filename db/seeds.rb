# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

internal_user = InternalUser.find_or_initialize_by(email: "internal@example.com")
internal_user.update!(
  name: "Internal User",
  password: "password123",
  active: true
)

puts "Seeded internal user: #{internal_user.email}"

products = [
  { sku: "BOX-001", name: "Shipping Box", price_cents: 1299 },
  { sku: "LABEL-001", name: "Shipping Label", price_cents: 49 },
  { sku: "TAPE-001", name: "Packing Tape", price_cents: 599 },
  { sku: "MAILER-001", name: "Mailer", price_cents: 249 }
].index_by { |attributes| attributes[:sku] }

products.each_value do |attributes|
  Product.find_or_initialize_by(sku: attributes[:sku]).update!(attributes.merge(active: true))
end

orders = [
  {
    number: "ORDER-1001",
    customer_name: "John First",
    customer_email: "john_first@example.com",
    shipping_address: "1111111 Market St, San Diego, CA 92130",
    status: "pending_review",
    submitted_at: 3.hours.ago,
    line_items: [ [ "BOX-001", 2 ], [ "LABEL-001", 2 ] ]
  },
  {
    number: "ORDER-1002",
    customer_name: "John Second",
    customer_email: "john_second@example.com",
    shipping_address: "22222 Market St, San Diego, CA 92130",
    status: "approved",
    submitted_at: 1.day.ago,
    line_items: [ [ "MAILER-001", 4 ], [ "TAPE-001", 1 ] ]
  },
  {
    number: "ORDER-1003",
    customer_name: "John Third",
    customer_email: "john_third@example.com",
    shipping_address: "33333 Market St, San Diego, CA 92130",
    status: "packed",
    submitted_at: 2.days.ago,
    line_items: [ [ "BOX-001", 1 ], [ "TAPE-001", 2 ] ]
  },
  {
    number: "ORDER-1004",
    customer_name: "John Fourth",
    customer_email: "john_fourth@example.com",
    shipping_address: "44444 Market St, San Diego, CA 92130",
    status: "shipped",
    submitted_at: 4.days.ago,
    line_items: [ [ "MAILER-001", 3 ], [ "LABEL-001", 3 ] ]
  }
]

orders.each do |attributes|
  line_items = attributes.delete(:line_items)
  order = Order.find_or_initialize_by(number: attributes[:number])
  order.update!(attributes)
  order.line_items.destroy_all

  line_items.each do |sku, quantity|
    product = Product.find_by!(sku: sku)
    order.line_items.create!(product: product, quantity: quantity)
  end
end

puts "Seeded #{Product.count} products and #{Order.count} orders"
