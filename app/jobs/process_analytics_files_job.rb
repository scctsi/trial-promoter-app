class ProcessAnalyticsFilesJob < ActiveJob::Base
  queue_as :default
 
  def perform
    AnalyticsFile.all.each do |analytics_file|
      analytics_file.process
    end
  end
end