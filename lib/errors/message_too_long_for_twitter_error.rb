class MessageTooLongForTwitterError < StandardError
  def initialize(message_id)
    super("Message content for message ID #{message_id} is too long for Twitter.")
  end
end