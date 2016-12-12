class MessageFactory
  def create(message_generating_instance, message_generation_parameter_set)
    messages = []
    
    message_constructor = MessageConstructor.new
    message_templates = MessageTemplate.belonging_to(message_generating_instance)
    websites = Website.belonging_to(message_generating_instance)

    message_generation_parameter_set.social_network_choices.each do |social_network|
      message_templates_for_social_network = message_templates.select{ |message_template| message_template.platform == social_network }
      message_generation_parameter_set.medium_choices.each do |medium|
        (0...message_generation_parameter_set.period_in_days).each do |day|
          message_generation_parameter_set.number_of_messages_per_social_network.times do |index|
            message = message_constructor.construct(message_generating_instance, message_templates_for_social_network.sample, websites.sample, medium)
            message.save
            messages << message
          end
        end
      end
    end
    
    if message_generation_parameter_set.image_present_choices.include?(:with)
      attach_images(messages, message_generation_parameter_set.image_present_distribution)
    end
    
    messages
  end
  
  def attach_images(messages, distribution=:equal)
    include_image = false
    
    messages.each do |message|
      if include_image
        image = FactoryGirl.create(:image)
        message.image_present = :with
        message.image = image
        message.save
      end
      
      include_image = !include_image
    end
  end
end

