class OrderLineItem < ApplicationRecord
  belongs_to :order, inverse_of: :line_items
  belongs_to :product

  before_validation :snapshot_product_price

  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def total_cents
    quantity * unit_price_cents
  end

  private

  def snapshot_product_price
    self.unit_price_cents ||= product&.price_cents
  end
end
