require 'rails_helper'

RSpec.describe MessageSetGenerator do
  before do
  end
end

    # it 'correctly calculates for one property, one message template, 3 social networks, 2 mediums, with and without images for 10 days and 1 message per network' do
    #   message_generation_parameter_set = MessageGenerationParameterSet.new(
    #     promoted_websites_tag: 'experiment', 
    #     selected_message_templates_tag: 'experiment', 
    #     social_network_cycle_type: :all,
    #     medium_cycle_type: :all,
    #     image_present_cycle_type: :all,
    #     period_in_days: 10,
    #     number_of_messages_per_social_network: 1
    #   )
      
    #   # Number of properties(1) * Number of message templates(1) * Number of social networks(3) * Number of mediums(2) * Image/No Image(2) * Period in days(10) * Number of messages per social network (1)
    #   expect(message_generation_parameter_set.expected_generated_message_count).to eq(1 * 1 * 3 * 2 * 2 * 10 * 1)
    # end

    # it 'correctly calculates for multiple properties, multiple templates, 3 social networks, 2 mediums, with and without images for 10 days and 1 message per network' do
    #   message_generation_parameter_set = MessageGenerationParameterSet.new(
    #     promoted_websites_tag: 'smoking',
    #     selected_message_templates_tag: 'experiment-2',
    #     social_network_cycle_type: :all,
    #     medium_cycle_type: :all,
    #     image_present_cycle_type: :all,
    #     period_in_days: 10,
    #     number_of_messages_per_social_network: 1
    #   )
      
    #   # Number of properties(2) * Number of message templates(3) * Number of social networks(3) * Number of mediums(2) * Image/No Image(2) * Period in days(10) * Number of messages per social network (1)
    #   expect(message_generation_parameter_set.expected_generated_message_count).to eq(2 * 3 * 3 * 2 * 2 * 10 * 1)
    # end
    
    # it 'correctly calculates for multiple properties, multiple templates, 3 social networks, randomized mediums, randomly with and without images for 10 days and 2 message per network' do
    #   message_generation_parameter_set = MessageGenerationParameterSet.new(
    #     promoted_websites_tag: 'smoking',
    #     selected_message_templates_tag: 'experiment-2',
    #     social_network_cycle_type: :all,
    #     medium_cycle_type: :random,
    #     image_present_cycle_type: :random,
    #     period_in_days: 10,
    #     number_of_messages_per_social_network: 2
    #   )
      
    #   # Number of properties(2) * Number of message templates(3) * Number of social networks(3) * Number of mediums(1 (random)) * Image/No Image(1 (random)) * Period in days(10) * Number of messages per social network (2)
    #   expect(message_generation_parameter_set.expected_generated_message_count).to eq(2 * 3 * 3 * 1 * 1 * 10 * 2)
    # end
