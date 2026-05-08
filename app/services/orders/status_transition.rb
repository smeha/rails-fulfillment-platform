module Orders
  class StatusTransition
    ACTION = "order.status_changed"
    # The waterfall transitions
    TRANSITIONS = {
      "pending_review" => %w[approved canceled],
      "approved" => %w[packed canceled],
      "packed" => %w[shipped canceled],
      "shipped" => %w[delivered],
      "delivered" => [],
      "canceled" => []
    }.freeze

    Result = Struct.new(:success, :order, :message, :audit_entry, keyword_init: true) do
      def success?
        success
      end
    end

    def self.available_statuses_for(status)
      TRANSITIONS.fetch(status.to_s, [])
    end

    def initialize(order, actor: nil)
      @order = order
      @actor = actor
    end

    def call(new_status)
      target_status = new_status.to_s

      return failure("Unknown order status: #{target_status}") unless Order::STATUSES.include?(target_status)
      return failure("Order is already #{human_status(order.status)}.") if target_status == order.status
      return failure(invalid_transition_message(target_status)) unless allowed?(target_status)

      audit_entry = nil
      previous_status = order.status

      Order.transaction do
        order.update!(status: target_status)
        audit_entry = AuditEntry.create!(
          auditable: order,
          actor: actor,
          action: ACTION,
          changed_attribute: "status",
          from_value: previous_status,
          to_value: target_status
        )
      end

      Result.new(
        success: true,
        order: order,
        audit_entry: audit_entry,
        message: "Order moved from #{human_status(previous_status)} to #{human_status(target_status)}."
      ).tap { enqueue_tracking_sync(target_status) }
    end

    private

    attr_reader :order, :actor

    def allowed?(target_status)
      self.class.available_statuses_for(order.status).include?(target_status)
    end

    def failure(message)
      Result.new(success: false, order: order, message: message)
    end

    def enqueue_tracking_sync(target_status)
      SyncTrackingEventsJob.perform_later(order) if target_status.in?(%w[shipped delivered])
    end

    def invalid_transition_message(target_status)
      next_statuses = self.class.available_statuses_for(order.status)

      return "Cannot move order from #{human_status(order.status)} to #{human_status(target_status)} because it is restricted." if next_statuses.empty?

      "Cannot move order from #{human_status(order.status)} to #{human_status(target_status)}. Available next statuses: #{next_statuses.map { |status| human_status(status) }.to_sentence}."
    end

    def human_status(status)
      status.to_s.humanize.downcase
    end
  end
end
