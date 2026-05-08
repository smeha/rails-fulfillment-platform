require "rails_helper"

RSpec.describe Orders::StatusTransition do
  describe "#call" do
    it "advances an order through a valid transition and writes an audit entry" do
      order = create(:order, status: "pending_review")

      result = described_class.new(order).call("approved")

      expect(result).to be_success
      expect(result.message).to eq("Order moved from pending review to approved.")
      expect(order.reload.status).to eq("approved")
      expect(order.audit_entries.count).to eq(1)

      audit_entry = order.audit_entries.sole
      expect(audit_entry).to have_attributes(
        action: "order.status_changed",
        changed_attribute: "status",
        from_value: "pending_review",
        to_value: "approved"
      )
    end

    it "rejects a transition that skips required steps" do
      order = create(:order, status: "pending_review")

      result = described_class.new(order).call("shipped")

      expect(result).not_to be_success
      expect(result.message).to eq("Cannot move order from pending review to shipped. Available next statuses: approved and canceled.")
      expect(order.reload.status).to eq("pending_review")
      expect(order.audit_entries).to be_empty
    end

    it "rejects changes from restricted statuses" do
      order = create(:order, status: "delivered")

      result = described_class.new(order).call("canceled")

      expect(result).not_to be_success
      expect(result.message).to eq("Cannot move order from delivered to canceled because it is restricted.")
      expect(order.reload.status).to eq("delivered")
    end

    it "rejects unknown statuses" do
      order = create(:order, status: "approved")

      result = described_class.new(order).call("lost")

      expect(result).not_to be_success
      expect(result.message).to eq("Unknown order status: lost")
      expect(order.reload.status).to eq("approved")
    end
  end
end
