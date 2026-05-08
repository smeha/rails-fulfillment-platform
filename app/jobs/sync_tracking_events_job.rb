class SyncTrackingEventsJob < ApplicationJob
  queue_as :default

  retry_on Carriers::Error, wait: 5.seconds, attempts: 3
  discard_on ActiveJob::DeserializationError

  def perform(order)
    result = Orders::TrackingSync.new(order).call
    raise Carriers::Error, result.message unless result.success?
  end
end
