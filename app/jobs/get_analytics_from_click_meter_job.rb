class GetAnalyticsFromClickMeterJob < ActiveJob::Base
  queue_as :default

  def perform
    updated_messages = Message.joins(:buffer_update).where( "message_id is not null")
    updated_messages.all.each do |message|
      ClickMeterClient.get_clicks(message.click_meter_tracking_link)
      Throttler.throttle(10)
    end
  end
end