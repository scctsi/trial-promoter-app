class MessageConstructor
  def construct(message_generating_instance, message_template, platform, medium = :organic)
    # A message_generating_instance is either an Experiment or Campaign, the two models that can generate messages.
    message = Message.new(content: message_template.content)
    
    message.content.gsub!('{url}', message_template.promoted_website_url) if !message.content.index('{url}').nil?
      
    # Set all associations so that we can trace the exact context in which a message was constructed.
    message.promoted_website_url = message_template.promoted_website_url
    message.message_generating = message_generating_instance
    message.message_template = message_template
    message.platform = platform
    message.medium = medium
    message
  end
end