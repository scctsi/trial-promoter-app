task :get_updates_from_buffer => :environment do
  GetUpdatesFromBufferJob.perform_later
end

task :publish_messages => :environment do
  PublishMessagesJob.perform_later
end

task :process_analytics_files => :environment do
  ProcessAnalyticsFilesJob.perform_later
end

task :calculate_click_and_goal_rate => :environment do
  CalculateClickAndGoalRateJob.perform_later
end
