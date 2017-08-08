class CalculateClickAndGoalRateJob < ActiveJob::Base
  queue_as :default

  def perform
    published_messages = Message.where(publish_status: :published_to_social_network)
    published_messages.each do |message|
      message.calculate_click_rate
      message.calculate_website_goal_rate(['128.125.77.139', '128.125.132.141', '207.151.120.4', '128.125.98.4', '128.125.109.224', '128.125.98.2', '68.181.124.25', '162.225.230.188', '216.4.202.66', '68.181.207.160', '2605:e000:8681:4900:a5c8:66d1:4753:fcc0', '68.101.127.18', '2602:306:80c8:88a0:89a:a5f6:7641:321c'])
      message.calculate_session_count(['128.125.77.139', '128.125.132.141', '207.151.120.4', '128.125.98.4', '128.125.109.224', '128.125.98.2', '68.181.124.25', '162.225.230.188', '216.4.202.66', '68.181.207.160', '2605:e000:8681:4900:a5c8:66d1:4753:fcc0', '68.101.127.18', '2602:306:80c8:88a0:89a:a5f6:7641:321c'])
      message.calculate_goal_count
    end
  end
end