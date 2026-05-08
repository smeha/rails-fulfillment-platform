module Orders
  class TrackingSync
    Result = Struct.new(:success, :order, :imported_count, :message, keyword_init: true) do
      def success?
        success
      end
    end

    def initialize(order, carrier_client: Carriers::SimulatedTrackingClient.new)
      @order = order
      @carrier_client = carrier_client
    end

    def call
      events = carrier_client.fetch_events(order)
      tracking_events = events.filter_map { |event| import_event(event) }

      Result.new(
        success: true,
        order: order,
        imported_count: tracking_events.size,
        message: "Imported #{tracking_events.size} tracking #{'event'.pluralize(tracking_events.size)}."
      )
    rescue Carriers::Error => e
      Result.new(success: false, order: order, imported_count: 0, message: e.message)
    end

    private

    attr_reader :order, :carrier_client

    def import_event(event)
      attributes = normalize_event(event)
      return if attributes.blank?

      tracking_event = order.tracking_events.find_or_initialize_by(external_id: attributes.fetch(:external_id))
      tracking_event.update!(attributes)
      tracking_event
    end

    def normalize_event(event)
      attributes = event.to_h.symbolize_keys

      {
        external_id: attributes.fetch(:external_id).to_s,
        carrier: attributes.fetch(:carrier).to_s,
        tracking_number: attributes.fetch(:tracking_number).to_s,
        status: attributes.fetch(:status).to_s,
        description: attributes.fetch(:description).to_s,
        occurred_at: attributes.fetch(:occurred_at),
        raw_payload: attributes.fetch(:raw_payload, {})
      }
    rescue KeyError, NoMethodError
      nil
    end
  end
end
