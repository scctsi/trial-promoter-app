class GetAnalyticsFromGoogleAnalyticsJob < ActiveJob::Base
  queue_as :default

  def perform
    google_analytics_client = GoogleAnalyticsClient.new('147198532')
    data = google_analytics_client.get_data(Date.new(2017,4,19).to_s, DateTime.now.to_date)
    GoogleAnalyticsDataParser.parse(data)
    GoogleAnalyticsDataParser.store(data)
  end
end