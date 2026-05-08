require "rails_helper"

RSpec.describe "Orders", type: :request do
  let(:internal_user) { create(:internal_user) }

  before do
    sign_in(internal_user)
  end

  describe "GET /orders" do
    it "shows orders with an optional status filter" do
      pending_order = create(:order, status: "pending_review")
      approved_order = create(:order, status: "approved")

      get orders_path(status: "approved")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(approved_order.number)
      expect(response.body).not_to include(pending_order.number)
      expect(response.body).to include("option selected=\"selected\" value=\"approved\"")
    end

    it "renders a status filter that submits when changed" do
      create(:order)

      get orders_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Filter by status")
      expect(response.body).to include("onchange=\"this.form.requestSubmit()\"")
    end

    it "rejects unknown filters without crashing" do
      create(:order)

      get orders_path(status: "lost")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Unknown order status filter: lost")
    end

    it "shows the first ten orders on page one" do
      orders = 11.times.map do |index|
        create(:order, submitted_at: (index + 1).minutes.ago)
      end

      get orders_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(orders.first.number)
      expect(response.body).not_to include(orders.last.number)
      expect(response.body).to include("Page 1 of 2")
      expect(response.body).to include("Next")
    end

    it "shows later orders on requested pages" do
      orders = 11.times.map do |index|
        create(:order, submitted_at: (index + 1).minutes.ago)
      end

      get orders_path(page: 2)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(orders.last.number)
      expect(response.body).not_to include(orders.first.number)
      expect(response.body).to include("Previous")
    end
  end

  describe "GET /orders/:id" do
    it "shows line items, available actions, and audit history" do
      order = create(:order)
      product = create(:product, name: "Mailer", price_cents: 249)
      create(:order_line_item, order: order, product: product, quantity: 2)
      order.transition_to("approved", actor: internal_user)

      get order_path(order)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mailer")
      expect(response.body).to include("$4.98")
      expect(response.body).to include("Move to Packed")
      expect(response.body).to include("Status changed from Pending review to Approved")
    end
  end

  describe "PATCH /orders/:id/status" do
    it "advances an order through a valid transition" do
      order = create(:order, status: "pending_review")

      patch status_order_path(order), params: { status: "approved" }

      expect(response).to redirect_to(order_path(order))
      expect(order.reload.status).to eq("approved")
      expect(order.audit_entries.sole.actor).to eq(internal_user)
    end

    it "shows a clear message for an invalid transition" do
      order = create(:order, status: "pending_review")

      patch status_order_path(order), params: { status: "shipped" }
      follow_redirect!

      expect(order.reload.status).to eq("pending_review")
      expect(response.body).to include("Cannot move order from pending review to shipped.")
    end
  end

  describe "PATCH /orders/bulk_status" do
    it "applies a transition to selected orders" do
      orders = create_list(:order, 2, status: "pending_review")

      patch bulk_status_orders_path, params: { order_ids: orders.map(&:id), status: "approved" }

      expect(response).to redirect_to(orders_path)
      expect(orders.map { |order| order.reload.status }).to contain_exactly("approved", "approved")
    end

    it "does not fail the whole request when one order cannot transition" do
      pending_order = create(:order, status: "pending_review")
      delivered_order = create(:order, status: "delivered")

      patch bulk_status_orders_path, params: { order_ids: [ pending_order.id, delivered_order.id ], status: "approved" }
      follow_redirect!

      expect(pending_order.reload.status).to eq("approved")
      expect(delivered_order.reload.status).to eq("delivered")
      expect(response.body).to include("1 order moved to approved; 1 order could not be updated.")
    end

    it "asks the user to select orders" do
      patch bulk_status_orders_path, params: { status: "approved" }
      follow_redirect!

      expect(response.body).to include("Select at least one order.")
    end
  end

  def sign_in(internal_user)
    post session_path, params: { session: { email: internal_user.email, password: internal_user.password } }
  end
end
