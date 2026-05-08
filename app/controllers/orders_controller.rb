class OrdersController < ApplicationController
  ORDERS_PER_PAGE = 10

  before_action :set_order, only: %i[show status]

  def index
    @statuses = Order::STATUSES
    @selected_status = params[:status].presence
    orders = Order.order(submitted_at: :desc, id: :desc)

    if @selected_status.in?(@statuses)
      orders = orders.where(status: @selected_status)
    elsif @selected_status.present?
      flash.now[:alert] = "Unknown order status filter: #{@selected_status}"
      @selected_status = nil
    end

    @total_orders = orders.count
    @total_pages = [ (@total_orders.to_f / ORDERS_PER_PAGE).ceil, 1 ].max
    @page = [ requested_page, @total_pages ].min
    @orders = orders.includes(:line_items).offset((@page - 1) * ORDERS_PER_PAGE).limit(ORDERS_PER_PAGE)
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
      redirect_to filtered_orders_path, alert: "Select at least one order."
      return
    end

    results = Order.where(id: order_ids).order(:id).map do |order|
      order.transition_to(params[:status], actor: current_internal_user)
    end

    redirect_to filtered_orders_path, flash_for_bulk_results(results, params[:status])
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def requested_page
    page = params[:page].to_i
    page.positive? ? page : 1
  end

  def filtered_orders_path
    orders_path(status: params[:filter_status].presence, page: params[:filter_page].presence)
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
