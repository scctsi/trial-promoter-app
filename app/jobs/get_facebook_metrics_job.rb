class GetFacebookMetricsJob < ActiveJob::Base
  queue_as :default

  def perform(page_id, date)
    facebook_metrics_aggregator = FacebookMetricsAggregator.new
    facebook_metrics_aggregator.get_posts(page_id, date)
  end
end