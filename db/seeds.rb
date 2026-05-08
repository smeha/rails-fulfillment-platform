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

customers = [
  { name: "John First", email: "john_first@example.com", address: "11111 Market St, San Diego, CA 92130" },
  { name: "John Second", email: "john_second@example.com", address: "22222 Market St, San Diego, CA 92130" },
  { name: "John Third", email: "john_third@example.com", address: "33333 Market St, San Diego, CA 92130" },
  { name: "John Fourth", email: "john_fourth@example.com", address: "44444 Market St, San Diego, CA 92130" },
  { name: "John Fifth", email: "john_fifth@example.com", address: "55555 Market St, San Diego, CA 92130" },
  { name: "John Sixth", email: "john_sixth@example.com", address: "66666 Market St, San Diego, CA 92130" },
  { name: "John Seventh", email: "john_seventh@example.com", address: "77777 Market St, San Diego, CA 92130" },
  { name: "John Eighth", email: "john_eighth@example.com", address: "88888 Market St, San Diego, CA 92130" }
]

line_item_sets = [
  { "BOX-001" => 2, "LABEL-001" => 2 },
  { "MAILER-001" => 4, "TAPE-001" => 1 },
  { "BOX-001" => 1, "TAPE-001" => 2 },
  { "MAILER-001" => 3, "LABEL-001" => 3 },
  { "BOX-001" => 3, "MAILER-001" => 2 },
  { "LABEL-001" => 10, "TAPE-001" => 1 }
]

orders = 24.times.map do |index|
  customer = customers[index % customers.length]

  {
    number: format("ORDER-%<number>04d", number: 1001 + index),
    customer_name: customer[:name],
    customer_email: customer[:email],
    shipping_address: customer[:address],
    status: Order::STATUSES[index % Order::STATUSES.length],
    submitted_at: (index + 3).hours.ago,
    line_items: line_item_sets[index % line_item_sets.length]
  }
end

orders.each do |attributes|
  line_items = attributes.fetch(:line_items)
  order = Order.find_or_initialize_by(number: attributes[:number])
  order.update!(attributes.except(:line_items))
  order.line_items.destroy_all

  line_items.each do |sku, quantity|
    product = Product.find_by!(sku: sku)
    order.line_items.create!(product: product, quantity: quantity)
  end

  Orders::TrackingSync.new(order).call if order.status.in?(%w[shipped delivered])
end

puts "Seeded #{Product.count} products, #{Order.count} orders, and #{TrackingEvent.count} tracking events"
