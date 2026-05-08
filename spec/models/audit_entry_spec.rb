require "rails_helper"

RSpec.describe AuditEntry do
  describe "defaults" do
    it "fills occurred_at and metadata before validation" do
      order = create(:order)

      entry = described_class.create!(auditable: order, action: "order.status_changed")

      expect(entry.occurred_at).to be_present
      expect(entry.metadata).to eq({})
    end
  end

  describe "immutability" do
    it "cannot be destroyed" do
      order = create(:order)
      entry = described_class.create!(auditable: order, action: "order.status_changed")

      expect { entry.destroy }.to raise_error(ActiveRecord::ReadOnlyRecord)
    end

    it "blocks destroying an order that has audit entries" do
      order = create(:order)
      described_class.create!(auditable: order, action: "order.status_changed")

      expect { order.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end

  describe ".recent" do
    it "orders entries newest-first" do
      order = create(:order)
      older = described_class.create!(auditable: order, action: "order.status_changed", occurred_at: 1.hour.ago)
      newer = described_class.create!(auditable: order, action: "order.status_changed", occurred_at: 1.minute.ago)

      expect(order.audit_entries.recent.to_a).to eq([ newer, older ])
    end
  end
end
