class PublishMessagesJob < ActiveJob::Base
  queue_as :default
 
  def perform
    pending_messages = Message.where(publish_status: :pending)

    pending_messages.all.each do |pending_message|
      BufferClient.create_update(pending_message)
    end
  end
end