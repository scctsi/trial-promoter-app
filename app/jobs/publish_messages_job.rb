class PublishMessagesJob < ActiveJob::Base
  queue_as :default
 
  def perform
    pending_messages = Message.where(publish_status: :pending)
    pending_messages = pending_messages.where('social_network_publish_date <= ?', Time.now + 7.days)

    pending_messages.all.each do |pending_message|
      BufferClient.create_update(pending_message)
    end
  end
end