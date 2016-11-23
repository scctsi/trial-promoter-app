class MessageSetGenerator
  def generate(experiment, message_generation_parameter_set)
    message_generator = MessageGenerator.new
    promoted_websites = Website.tagged_with(message_generation_parameter_set.promoted_websites_tag)
    selected_message_templates = MessageTemplate.tagged_with(message_generation_parameter_set.selected_message_templates_tag)

    promoted_websites.each do |website|
      SocialNetworks::SUPPORTED_NETWORKS.each do |social_network|
        mediums = [:ad, :organic]
        mediums.each do |medium|
          image_present_cycle_choices = [false, true]
          image_present_cycle_choices.each do |image_present_cycle_choice|
            (0...message_generation_parameter_set.period_in_days).each do |day|
              message_generation_parameter_set.number_of_messages_per_social_network.times do |index|
                message = message_generator.generate(selected_message_templates.sample, promoted_websites.sample)
                message.save
              end
            end
          end
        end
      end
    end
  end
end