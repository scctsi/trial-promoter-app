class GenerateMessagesJob < ActiveJob::Base
  queue_as :default
 
  def perform(experiment)
    experiment.create_messages
  end
end