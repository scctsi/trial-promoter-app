class PeriodicWorker
  # TODO: Unit test this class

  # This class contains all the code that needs to run periodically in order to:
  # 1. Gather metrics from Buffer
  # 2. Generate new message
  # 3. Send messages to Buffer
  def work
    # 1. Gather metrics from Buffer
    Message.all.each do |message|
      Buffer.get_update(message)
    end
    
    # 2. Generate new messages for trials that need promotion
    message_generator = MessageGenerator.new
    trials_needing_promotion = message_generator.get_trials_needing_promotion
    messages = message_generator.create_promotion_messages()
    
    # 3. Send all the newly generated messages to Buffer
    # TODO: How do we control the amount of messages sent to Buffer?
    messages.all.each do |message|
      Buffer.create_update(message)
    end
  end
end