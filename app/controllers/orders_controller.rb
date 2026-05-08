class OrdersController < ApplicationController
  before_action :set_order, only: %i[show status]

  def index
    @statuses = Order::STATUSES
    @selected_status = params[:status].presence
    @orders = Order.includes(:line_items).order(submitted_at: :desc, id: :desc)

    if @selected_status.in?(@statuses)
      @orders = @orders.where(status: @selected_status)
    elsif @selected_status.present?
      flash.now[:alert] = "Unknown order status filter: #{@selected_status}"
      @selected_status = nil
    end
  end

  def show
    @line_items = @order.line_items.includes(:product)
    @audit_entries = @order.audit_entries.includes(:actor).recent
  end

  def status
    result = @order.transition_to(params[:status], actor: current_internal_user)
    flash[result.success? ? :notice : :alert] = result.message

    redirect_to @order
  end

  def bulk_status
    order_ids = Array(params[:order_ids]).compact_blank

    if order_ids.empty?
      redirect_to orders_path(status: params[:filter_status]), alert: "Select at least one order."
      return
    end

    results = Order.where(id: order_ids).order(:id).map do |order|
      order.transition_to(params[:status], actor: current_internal_user)
    end

    redirect_to orders_path(status: params[:filter_status]), flash_for_bulk_results(results, params[:status])
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def flash_for_bulk_results(results, status)
    successes = results.count(&:success?)
    failures = results.size - successes

    if failures.zero?
      { notice: "#{successes} #{'order'.pluralize(successes)} moved to #{status.to_s.humanize.downcase}." }
    else
      { alert: "#{successes} #{'order'.pluralize(successes)} moved to #{status.to_s.humanize.downcase}; #{failures} #{'order'.pluralize(failures)} could not be updated." }
    end
  end
end
