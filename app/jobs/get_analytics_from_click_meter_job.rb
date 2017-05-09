class GetAnalyticsFromClickMeterJob < ActiveJob::Base
  queue_as :default
 
  def perform
    published_messages = Message.where(publish_status: :published_to_social_network)
    published_messages.each do |message|
      ClickMeterClient.get_clicks(tracking_link)
    # Throttler.throttle(10)  
    end
  end
end