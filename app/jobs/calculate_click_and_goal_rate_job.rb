class CalculateClickAndGoalRateJob < ActiveJob::Base
  queue_as :default

  def perform
    published_messages = Message.where(publish_status: :published_to_social_network)
    published_messages.each do |message|
      message.calculate_click_rate
      message.calculate_website_goal_rate
      message.calculate_session_count
      message.calculate_goal_count
    end
  end
end