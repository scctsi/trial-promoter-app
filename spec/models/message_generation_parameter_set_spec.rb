# == Schema Information
#
# Table name: message_generation_parameter_sets
#
#  id                                    :integer          not null, primary key
#  medium_distribution                   :string
#  social_network_distribution           :string
#  image_present_distribution            :string
#  period_in_days                        :integer
#  number_of_messages_per_social_network :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  message_generating_id                 :integer
#  message_generating_type               :string
#  social_network_choices                :text
#  medium_choices                        :text
#  image_choices                         :text
#

require 'rails_helper'

describe MessageGenerationParameterSet do
  it { is_expected.to enumerize(:social_network_distribution).in(:equal, :random).with_default(:equal) }
  it { is_expected.to enumerize(:medium_distribution).in(:equal, :random).with_default(:equal) }
  it { is_expected.to enumerize(:image_present_distribution).in(:equal, :random).with_default(:equal) }
  it { is_expected.to validate_presence_of :period_in_days }
  it { is_expected.to validate_presence_of :number_of_messages_per_social_network }
  # TODO: Test period_in_days is an integer >= 0
  # TODO: Test number_of_messages_per_social_network is an integer >= 0
  it { is_expected.to validate_presence_of :message_generating }
  it { is_expected.to belong_to(:message_generating) }

  it 'stores an array of social network choices' do
    message_generation_parameter_set = build(:message_generation_parameter_set)
    message_generation_parameter_set.social_network_choices = ['instagram', 'twitter']
    
    message_generation_parameter_set.save
    message_generation_parameter_set.reload
    
    expect(message_generation_parameter_set.social_network_choices).to eq(['instagram', 'twitter'])
  end

  it 'stores an array of medium choices' do
    message_generation_parameter_set = build(:message_generation_parameter_set)
    message_generation_parameter_set.medium_choices = ['ad', 'organic']
    
    message_generation_parameter_set.save
    message_generation_parameter_set.reload
    
    expect(message_generation_parameter_set.medium_choices).to eq(['ad', 'organic'])
  end

  it 'stores an array of image choices' do
    message_generation_parameter_set = build(:message_generation_parameter_set)
    message_generation_parameter_set.image_present_choices = ['with', 'without']
    
    message_generation_parameter_set.save
    message_generation_parameter_set.reload
    
    expect(message_generation_parameter_set.image_present_choices).to eq(['with', 'without'])
  end

  describe 'calculating the number of generated messages' do
    before do
      experiment = create(:experiment)
      @websites = create(:website, experiment_list: experiment.to_param)
      @message_templates = create_list(:message_template, 5, experiment_list: experiment.to_param)
    end
    
    it 'is correct when the parameters include one website, five message templates, 1 social network (equal distribution), 1 medium (equal distribution), with images (equal distribution), for 10 days and 3 messages per network per day' do
      message_generation_parameter_set = MessageGenerationParameterSet.new(
        social_network_choices: ['facebook'],
        social_network_distribution: :equal,
        medium_choices: ['ad'],
        medium_distribution: :equal,
        image_present_choices: ['with'],
        image_present_distribution: :equal,
        period_in_days: 10,
        number_of_messages_per_social_network: 3
      )
      
      # Number of social networks (1) * Number of mediums (1) * Number of image present choices (1) * Period in days(10) * Number of messages per social network (3)
      expect(message_generation_parameter_set.expected_generated_message_count).to eq(1 * 1 * 1 * 10 * 3)
    end

    it 'is correct when the parameters include one website, five message templates, 3 social networks (equal distribution), 2 mediums (equal distribution), with and without images (equal distribution), for 10 days and 3 messages per network per day' do
      message_generation_parameter_set = MessageGenerationParameterSet.new(
        social_network_choices: ['facebook', 'twitter', 'instagram'],
        social_network_distribution: :equal,
        medium_choices: ['ad', 'organic'],
        medium_distribution: :equal,
        image_present_choices: ['with', 'without'],
        image_present_distribution: :equal,
        period_in_days: 10,
        number_of_messages_per_social_network: 3
      )
      
      # Number of social networks (1) * Number of mediums (1) * Number of image present choices (1) * Period in days(10) * Number of messages per social network (3)
      expect(message_generation_parameter_set.expected_generated_message_count).to eq(3 * 2 * 2 * 10 * 3)
    end
  end
end
