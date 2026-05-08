module Carriers
  class SimulatedTrackingClient
    CARRIER = "Simulated Carrier"

    Event = Struct.new(
      :external_id,
      :carrier,
      :tracking_number,
      :status,
      :description,
      :occurred_at,
      :raw_payload,
      keyword_init: true
    )

    def fetch_events(order)
      raise Error, "Tracking is only available after shipment." unless order.status.in?(%w[shipped delivered])

      tracking_number = tracking_number_for(order)
      events = [
        event(order, tracking_number, "label_created", "Shipping label created", 1.hour.ago),
        event(order, tracking_number, "accepted", "Package accepted by carrier", 50.minutes.ago),
        event(order, tracking_number, "in_transit", "Package is in transit", 30.minutes.ago)
      ]

      if order.status == "delivered"
        events << event(order, tracking_number, "delivered", "Package delivered", Time.current)
      end

      events
    end

    private

    def event(order, tracking_number, status, description, occurred_at)
      Event.new(
        external_id: "#{order.number}-#{status}",
        carrier: CARRIER,
        tracking_number: tracking_number,
        status: status,
        description: description,
        occurred_at: occurred_at,
        raw_payload: {
          order_number: order.number,
          status: status,
          description: description
        }
      )
    end

    def tracking_number_for(order)
      "SIMULATED_CARRIER-#{order.number.delete('^0-9').rjust(10, '0')}"
    end
  end
end
