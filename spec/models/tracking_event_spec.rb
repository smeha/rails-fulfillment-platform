require "rails_helper"

RSpec.describe TrackingEvent do
  describe "validations" do
    it "requires the carrier-supplied identifying fields" do
      event = described_class.new

      expect(event).not_to be_valid
      expect(event.errors.attribute_names).to include(
        :external_id, :carrier, :tracking_number, :status, :description, :occurred_at
      )
    end

    it "scopes external_id uniqueness to the order" do
      order = create(:order, status: "shipped")
      create(:tracking_event, order: order, external_id: "evt-1")
      duplicate = build(:tracking_event, order: order, external_id: "evt-1")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:external_id]).to include("has already been taken")
    end

    it "allows the same external_id on a different order" do
      first_order = create(:order, status: "shipped")
      second_order = create(:order, status: "shipped")
      create(:tracking_event, order: first_order, external_id: "evt-1")

      expect(build(:tracking_event, order: second_order, external_id: "evt-1")).to be_valid
    end
  end

  describe ".chronological" do
    it "orders events by occurred_at ascending" do
      order = create(:order, status: "shipped")
      later = create(:tracking_event, order: order, external_id: "evt-2", occurred_at: 1.minute.ago)
      earlier = create(:tracking_event, order: order, external_id: "evt-1", occurred_at: 10.minutes.ago)

      expect(order.tracking_events.chronological).to eq([ earlier, later ])
    end
  end
end
