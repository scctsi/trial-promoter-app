class MessageFactory
  def create(experiment, message_generation_parameter_set)
    message_constructor = MessageConstructor.new

    # promoted_websites.each do |website|
    #   SocialNetworks::SUPPORTED_NETWORKS.each do |social_network|
    #     mediums = [:ad, :organic]
    #     mediums.each do |medium|
    #       image_present_cycle_choices = [false, true]
    #       image_present_cycle_choices.each do |image_present_cycle_choice|
    #         (0...message_generation_parameter_set.period_in_days).each do |day|
    #           message_generation_parameter_set.number_of_messages_per_social_network.times do |index|
    #             message = message_generator.generate(selected_message_templates.sample, promoted_websites.sample)
    #             message.save
    #           end
    #         end
    #       end
    #     end
    #   end
    # end
  end
end