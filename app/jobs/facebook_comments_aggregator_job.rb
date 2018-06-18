class FacebookCommentsAggregatorJob < ActiveJob::Base
  queue_as :default
 
  def perform(experiment)
    facebook_comments_aggregator = FacebookCommentsAggregator.new(experiment)
  end
end