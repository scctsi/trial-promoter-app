class GetFacebookMetricsJob < ActiveJob::Base
  queue_as :default

  def perform(page_id, start_date, end_date)
    facebook_metrics_aggregator = FacebookMetricsAggregator.new
    facebook_metrics_aggregator.get_posts(page_id, start_date, end_date)
  end
end