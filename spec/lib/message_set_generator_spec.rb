require 'rails_helper'

RSpec.describe MessageSetGenerator do
  before do
    @message_generation_parameter_set = MessageGenerationParameterSet.new
    @message_set_generator = MessageSetGenerator.new
    @experiment = create(:experiment)
    @websites = create_list(:website, 5)
    @websites[0].tag_list.add('experiment')
    @websites[0].save
    @websites[1].tag_list.add('smoking')
    @websites[1].save
    @websites[2].tag_list.add('smoking')
    @websites[2].save
    @websites[3].tag_list.add('smoking')
    @websites[3].save
    @websites[3].tag_list.add('diabetes')
    @websites[3].save
    @message_templates = create_list(:message_template, 5)
    @message_templates[0].tag_list.add('experiment')
    @message_templates[0].save
    @message_templates[1].tag_list.add('experiment-2')
    @message_templates[1].save
    @message_templates[2].tag_list.add('experiment-2')
    @message_templates[2].save
    @message_templates[3].tag_list.add('experiment-3')
    @message_templates[3].save
    @message_templates[4].tag_list.add('experiment-3')
    @message_templates[4].save
  end

  it 'correctly creates messages for one property, one message template, 3 social networks, 2 mediums, with and without images for 10 days and 1 message per network' do
    @message_generation_parameter_set.promoted_websites_tag = 'experiment'
    @message_generation_parameter_set.selected_message_templates_tag = 'experiment'
    @message_generation_parameter_set.social_network_cycle_type = :all
    @message_generation_parameter_set.medium_cycle_type = :all
    @message_generation_parameter_set.image_present_cycle_type = :all
    @message_generation_parameter_set.period_in_days = 10
    @message_generation_parameter_set.number_of_messages_per_social_network = 1

    @message_set_generator.generate(@experiment, @message_generation_parameter_set) 
    
    expect(Message.count).to eq(@message_generation_parameter_set.expected_generated_message_count)
  end
end


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
