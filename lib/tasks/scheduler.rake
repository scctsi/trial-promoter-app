task :get_updates_from_buffer => :environment do
  GetUpdatesFromBufferJob.perform_later
end

task :publish_messages => :environment do
  experiment = Experiment.first
  PublishMessagesJob.perform_later(experiment)
end

task :process_analytics_files => :environment do
  ProcessAnalyticsFilesJob.perform_later
end