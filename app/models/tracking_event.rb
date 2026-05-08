class TrackingEvent < ApplicationRecord
  belongs_to :order

  validates :external_id, :carrier, :tracking_number, :status, :description, :occurred_at, presence: true
  validates :external_id, uniqueness: { scope: :order_id }

  scope :chronological, -> { order(occurred_at: :asc, id: :asc) }
end
