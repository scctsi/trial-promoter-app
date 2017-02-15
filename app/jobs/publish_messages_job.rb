class PublishMessagesJob < ActiveJob::Base
  queue_as :default
 
  def perform
    pending_messages = Message.where(publish_status: :pending)
    pending_messages = pending_messages.where('scheduled_date_time <= ?', Time.now + 7.days)

    pending_messages.all.each do |pending_message|
      BufferClient.create_update(pending_message) unless (pending_message.message_template.platform == :instagram && pending_message.medium == :organic)
    end
  end
end