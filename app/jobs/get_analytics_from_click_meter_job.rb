class GetAnalyticsFromClickMeterJob < ActiveJob::Base
  queue_as :default

  def perform(experiment)
    updated_messages = Message.where(publish_status: :published_to_buffer)
    updated_messages.all.each do |message|
      ClickMeterClient.get_clicks(experiment, message.click_meter_tracking_link)
      Throttler.throttle(10)
    end
  end
end