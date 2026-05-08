class Product < ApplicationRecord
  has_many :order_line_items, dependent: :restrict_with_exception

  validates :sku, presence: true, uniqueness: true
  validates :name, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :active, inclusion: { in: [ true, false ] }
end
