require "rails_helper"

RSpec.describe Product do
  describe "validations" do
    it "requires sku, name, and a non-negative integer price" do
      product = described_class.new

      expect(product).not_to be_valid
      expect(product.errors.attribute_names).to include(:sku, :name, :price_cents)
    end

    it "rejects duplicate skus" do
      create(:product, sku: "BOX-001")
      duplicate = build(:product, sku: "BOX-001")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:sku]).to include("has already been taken")
    end

    it "rejects negative prices" do
      product = build(:product, price_cents: -1)

      expect(product).not_to be_valid
      expect(product.errors[:price_cents]).to be_present
    end
  end

  describe "deletion" do
    it "blocks deletion when line items reference the product" do
      product = create(:product)
      order = create(:order)
      create(:order_line_item, order: order, product: product)

      expect { product.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end
end
