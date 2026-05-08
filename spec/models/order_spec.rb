require "rails_helper"

RSpec.describe Order do
  describe "#total_cents" do
    it "sums line item totals using integer cents" do
      order = create(:order)
      box = create(:product, price_cents: 1299)
      tape = create(:product, price_cents: 599)

      create(:order_line_item, order: order, product: box, quantity: 2)
      create(:order_line_item, order: order, product: tape, quantity: 1)

      expect(order.total_cents).to eq(3197)
    end
  end

  describe "#available_statuses" do
    it "returns the next statuses allowed by the lifecycle" do
      order = build(:order, status: "pending_review")

      expect(order.available_statuses).to contain_exactly("approved", "canceled")
    end
  end
end
