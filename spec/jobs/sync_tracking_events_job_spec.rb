require "rails_helper"

RSpec.describe SyncTrackingEventsJob do
  describe "#perform" do
    it "imports tracking events through Orders::TrackingSync" do
      order = create(:order, status: "shipped")

      described_class.new.perform(order)

      expect(order.tracking_events.count).to eq(3)
    end

    it "re-raises Carriers::Error so the job can retry when the boundary fails" do
      order = create(:order, status: "shipped")
      tracking_sync = instance_double(Orders::TrackingSync)
      failure = Orders::TrackingSync::Result.new(
        success: false,
        order: order,
        imported_count: 0,
        message: "Carrier timeout"
      )
      allow(Orders::TrackingSync).to receive(:new).with(order).and_return(tracking_sync)
      allow(tracking_sync).to receive(:call).and_return(failure)

      expect { described_class.new.perform(order) }.to raise_error(Carriers::Error, "Carrier timeout")
    end
  end
end
