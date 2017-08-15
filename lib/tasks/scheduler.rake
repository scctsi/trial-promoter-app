task :get_updates_from_buffer => :environment do
  GetUpdatesFromBufferJob.perform_later
end

task :publish_messages, [:number_of_days] => :environment do |t, args|
  PublishMessagesJob.perform_later(args[:number_of_days])
end

task :process_analytics_files => :environment do
  ProcessAnalyticsFilesJob.perform_later
end

task :calculate_click_and_goal_rate => :environment do
  CalculateClickAndGoalRateJob.perform_later
end

task :get_analytics_from_google_analytics => :environment do
  GetAnalyticsFromGoogleAnalyticsJob.perform_later
end
