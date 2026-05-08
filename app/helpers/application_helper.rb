module ApplicationHelper
  def format_cents(cents)
    number_to_currency(cents.to_i / 100.0)
  end

  def human_status(status)
    status.to_s.humanize
  end
end
