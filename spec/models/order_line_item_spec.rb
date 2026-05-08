require "rails_helper"

RSpec.describe OrderLineItem do
  describe "validations" do
    it "snapshots the product price when the line item is created" do
      product = create(:product, price_cents: 1299)
      order = build(:order)

      line_item = build(:order_line_item, order: order, product: product, quantity: 3)

      expect(line_item).to be_valid
      expect(line_item.unit_price_cents).to eq(1299)
      expect(line_item.total_cents).to eq(3897)
    end

    it "keeps an explicit unit price when provided" do
      product = create(:product, price_cents: 599)
      order = build(:order)

      line_item = build(:order_line_item, order: order, product: product, quantity: 2, unit_price_cents: 499)

      expect(line_item).to be_valid
      expect(line_item.unit_price_cents).to eq(499)
      expect(line_item.total_cents).to eq(998)
    end
  end
end
