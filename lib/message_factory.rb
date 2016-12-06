class MessageFactory
  def create(experiment, message_generation_parameter_set)
    message_constructor = MessageConstructor.new

    # message_generation_parameter_set.social_network_choices.each do |social_network|
    #   message_generation_parameter_set.medium_choices.each do |medium|
    #     message_generation_paramter_set.image_present_choices.each do |image_present_choice| 
    #       (0...message_generation_parameter_set.period_in_days).each do |day|
    #         message_generation_parameter_set.number_of_messages_per_social_network.times do |index|
    #           message = message_constructor.generate(selected_message_templates.sample, promoted_websites.sample)
    #           message.save
    #         end
    #       end
    #     end
    #   end
    # end
  end
end