desc "This task is called by the Heroku scheduler add-on"

task :update_data => :environment do
  d = DataImporter.new
  d.import_buffer_data
  d.process_buffer_data
  d.import_twitter_data
  d.process_twitter_data
  d.import_facebook_data
  d.process_facebook_data
  d.import_google_analytics_data
  d.process_google_analytics_data
end