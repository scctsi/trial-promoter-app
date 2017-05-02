class GetAnalyticsFromClickMeterJob < ActiveJob::Base
  queue_as :default
 
  def perform(tracking_link)
    ClickMeterClient.get_clicks(tracking_link)
  end
end