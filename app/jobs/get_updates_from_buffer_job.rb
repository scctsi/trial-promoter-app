class GetUpdatesFromBufferJob < ActiveJob::Base
  queue_as :default
 
  def perform(experiment)
    messages_with_pending_buffer_update = Message.joins(:buffer_update).where('buffer_updates.status = ?', 'pending')

    messages_with_pending_buffer_update.all.each do |message_with_pending_buffer_update|
      BufferClient.get_update(experiment, message_with_pending_buffer_update)
      Throttler.throttle(1)
    end
  end
end