require "rails_helper"

RSpec.describe Orders::TrackingSync do
  it "imports tracking events from the carrier boundary" do
    order = create(:order, status: "shipped")

    result = described_class.new(order).call

    expect(result).to be_success
    expect(result.imported_count).to eq(3)
    expect(order.tracking_events.count).to eq(3)
    expect(order.tracking_events.chronological.first.status).to eq("label_created")
  end

  it "updates existing tracking events without duplicating them" do
    order = create(:order, status: "shipped")

    described_class.new(order).call
    described_class.new(order).call

    expect(order.tracking_events.count).to eq(3)
  end

  it "returns a failure when the carrier boundary fails" do
    order = create(:order, status: "shipped")
    carrier_client = instance_double(Carriers::SimulatedTrackingClient)
    allow(carrier_client).to receive(:fetch_events).and_raise(Carriers::Error, "Carrier timeout")

    result = described_class.new(order, carrier_client: carrier_client).call

    expect(result).not_to be_success
    expect(result.message).to eq("Carrier timeout")
  end
end
