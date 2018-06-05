class AggregateFacebookCommentsJob < ActiveJob::Base
  queue_as :default
 
  def perform(experiment)
    FacebookCommentsAggregator(experiment.configure_settings.facebook_access_token)
  end
end