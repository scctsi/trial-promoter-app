class GetAnalyticsFromClickMeterJob < ActiveJob::Base
  queue_as :default
 
  def perform
    published_messages = Message.where(publish_status: :published_to_social_network)
    published_messages.all.each do |message|
      ClickMeterClient.get_clicks(message.click_meter_tracking_link)
      Throttler.throttle(10)
    end
  end
end