class MessageFactory
  def create(message_generating_instance, message_generation_parameter_set)
    message_constructor = MessageConstructor.new
    message_templates = MessageTemplate.belonging_to(message_generating_instance)
    websites = Website.belonging_to(message_generating_instance)

    message_generation_parameter_set.social_network_choices.each do |social_network|
      message_templates_for_social_network = message_templates.select{ |message_template| message_template.platform == social_network }
      message_generation_parameter_set.medium_choices.each do |medium|
        message_generation_parameter_set.image_present_choices.each do |image_present_choice| 
          (0...message_generation_parameter_set.period_in_days).each do |day|
            message_generation_parameter_set.number_of_messages_per_social_network.times do |index|
              message = message_constructor.construct(message_generating_instance, message_templates_for_social_network.sample, websites.sample)
              message.save
            end
          end
        end
      end
    end
  end
end

