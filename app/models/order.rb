class Order < ApplicationRecord
  STATUSES = %w[pending_review approved packed shipped delivered canceled].freeze

  has_many :line_items, class_name: "OrderLineItem", dependent: :destroy, inverse_of: :order
  has_many :products, through: :line_items
  has_many :audit_entries, as: :auditable, dependent: :destroy

  validates :number, presence: true, uniqueness: true
  validates :customer_name, :customer_email, :shipping_address, :submitted_at, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  def total_cents
    line_items.sum(&:total_cents)
  end

  def available_statuses
    Orders::StatusTransition.available_statuses_for(status)
  end

  def transition_to(new_status, actor: nil)
    Orders::StatusTransition.new(self, actor: actor).call(new_status)
  end
end
