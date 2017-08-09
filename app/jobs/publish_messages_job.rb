class PublishMessagesJob < ActiveJob::Base
  queue_as :default
 
  def perform(number_of_days = 7)
    pending_messages = Message.where(publish_status: :pending)
    pending_messages = pending_messages.where('scheduled_date_time <= ?', Time.now + (number_of_days.to_i) * 60 * 60 * 24)

    pending_messages.all.each do |pending_message|
      BufferClient.create_update(pending_message) unless (pending_message.platform == :instagram && pending_message.medium == :organic)
      Throttler.throttle(1)
    end
  end
end