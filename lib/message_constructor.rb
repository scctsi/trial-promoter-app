class MessageConstructor
  def construct(message_generating_instance, message_template, promotable_instance, medium=:organic, image=nil)
    # A message_generating_instance is either an Experiment or Campaign, the two models that can generate messages.
    # A promotable_instance is either a ClinicalTrial or a Website, the two models that can be promoted by a message.
    message = Message.new(content: message_template.content)
    
    MessageTemplate::STANDARD_VARIABLES.each do |variable|
      matches = message.content.scan(variable)
      
      if matches.size > 0
        # The attribute name that we need to substitute is the variable without the surrounding curly braces
        # Example when the variable is {pi_first_name}, we need to get the value of pi_first_name from the clinical trial
        attribute_name = matches[0].gsub('{', '').gsub('}', '')
        message.content.gsub!(matches[0], promotable_instance.send(attribute_name))
      end
    end
    
    # Set all associations so that we can trace the exact context in which a message was constructed.
    message.promotable = promotable_instance
    message.message_generating = message_generating_instance
    message.message_template = message_template
    message.medium = medium
    message.image_present = :without
    if !image.nil?
      message.image_present = :with
      message.image = image
    end
    message
  end
end