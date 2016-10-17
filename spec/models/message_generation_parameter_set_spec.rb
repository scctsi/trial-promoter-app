# == Schema Information
#
# Table name: message_set_generation_parameter_sets
#
#  id                                    :integer          not null, primary key
#  promoted_websites_tag                 :string
#  promoted_clinical_trials_tag          :string
#  promoted_properties_cycle_type        :string
#  selected_message_templates_tag        :string
#  selected_message_templates_cycle_type :string
#  medium_cycle_type                     :string
#  social_network_cycle_type             :string
#  image_present_cycle_type              :string
#  period_in_days                        :integer
#  number_of_messages_per_social_network :integer
#  experiment_id                         :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#

require 'rails_helper'

describe MessageGenerationParameterSet do
  # TODO: Either promoted_websites_tag or promoted_clinical_trials_tag must not be blank
  it { is_expected.to enumerize(:promoted_properties_cycle_type).in(:all, :random).with_default(:all) }
  it { is_expected.to validate_presence_of :selected_message_templates_tag }
  it { is_expected.to enumerize(:selected_message_templates_cycle_type).in(:all, :random).with_default(:all) }
  it { is_expected.to enumerize(:social_network_cycle_type).in(:all, :subset).with_default(:all) }
  it { is_expected.to enumerize(:medium_cycle_type).in(:all, :random, :subset).with_default(:all) }
  it { is_expected.to enumerize(:image_present_cycle_type).in(:all, :random, :subset).with_default(:all) }
  it { is_expected.to validate_presence_of :period_in_days }
  it { is_expected.to validate_presence_of :number_of_messages_per_social_network }
  # TODO: Test period_in_days is an integer >= 0
  # TODO: Test number_of_messages_per_social_network is an integer >= 0
  it { is_expected.to belong_to(:experiment) }
  
  context 'calculating the number of messages that will be generated' do
    before do
      @websites = create_list(:website, 5)
      @websites[0].tag_list.add('experiment')
      @websites[0].save
      @websites[1].tag_list.add('smoking')
      @websites[1].save
      @websites[2].tag_list.add('smoking')
      @websites[2].save
      @websites[3].tag_list.add('smoking')
      @websites[3].save
      @message_templates = create_list(:message_template, 5)
      @message_templates[0].tag_list.add('experiment')
      @message_templates[0].save
      @message_templates[1].tag_list.add('experiment-2')
      @message_templates[1].save
      @message_templates[2].tag_list.add('experiment-2')
      @message_templates[2].save
    end
    
    it 'correctly calculates for one property, one message template, 3 social networks, 2 mediums, with and without images for 10 days and 1 message per network' do
      message_generation_parameter_set = MessageGenerationParameterSet.new(
        promoted_websites_tag: 'experiment', 
        selected_message_templates_tag: 'experiment', 
        social_network_cycle_type: :all,
        medium_cycle_type: :all,
        image_present_cycle_type: :all,
        period_in_days: 10,
        number_of_messages_per_social_network: 1
      )
      
      # Number of properties(1) * Number of message templates(1) * Number of social networks(3) * Number of mediums(2) * Image/No Image(2) * Period in days(10) * Number of messages per social network (1)
      expect(message_generation_parameter_set.expected_message_set_count).to eq(1 * 1 * 3 * 2 * 2 * 10 * 1)
    end

    it 'correctly calculates for multiple properties, multiple templates, 3 social networks, 2 mediums, with and without images for 10 days and 1 message per network' do
      message_generation_parameter_set = MessageGenerationParameterSet.new(
        promoted_websites_tag: 'smoking',
        selected_message_templates_tag: 'experiment-2',
        social_network_cycle_type: :all,
        medium_cycle_type: :all,
        image_present_cycle_type: :all,
        period_in_days: 10,
        number_of_messages_per_social_network: 1
      )
      
      # Number of properties(2) * Number of message templates(3) * Number of social networks(3) * Number of mediums(2) * Image/No Image(2) * Period in days(10) * Number of messages per social network (1)
      expect(message_generation_parameter_set.expected_message_set_count).to eq(2 * 3 * 3 * 2 * 2 * 10 * 1)
    end
    
    it 'correctly calculates for multiple properties, multiple templates, 3 social networks, randomized mediums, randomly with and without images for 10 days and 2 message per network' do
      message_generation_parameter_set = MessageGenerationParameterSet.new(
        promoted_websites_tag: 'smoking',
        selected_message_templates_tag: 'experiment-2',
        social_network_cycle_type: :all,
        medium_cycle_type: :random,
        image_present_cycle_type: :random,
        period_in_days: 10,
        number_of_messages_per_social_network: 2
      )
      
      # Number of properties(2) * Number of message templates(3) * Number of social networks(3) * Number of mediums(1 (random)) * Image/No Image(1 (random)) * Period in days(10) * Number of messages per social network (2)
      expect(message_generation_parameter_set.expected_message_set_count).to eq(2 * 3 * 3 * 1 * 1 * 10 * 2)
    end
  end
end
