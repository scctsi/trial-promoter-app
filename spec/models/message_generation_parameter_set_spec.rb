# == Schema Information
#
# Table name: message_generation_parameter_sets
#
#  id                                    :integer          not null, primary key
#  period_in_days                        :integer
#  number_of_messages_per_social_network :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  message_generating_id                 :integer
#  message_generating_type               :string
#  social_network_choices                :text
#  medium_choices                        :text
#  image_present_choices                 :text
#  number_of_cycles                      :integer
#

require 'rails_helper'

describe MessageGenerationParameterSet do
  it { is_expected.to validate_presence_of :number_of_cycles }
  it { is_expected.to validate_presence_of :number_of_messages_per_social_network }
  it { is_expected.to validate_presence_of :message_generating }
  it { is_expected.to belong_to(:message_generating) }
  it { is_expected.to serialize(:social_network_choices).as(Array) }
  it { is_expected.to serialize(:medium_choices).as(Array) }
  it { is_expected.to enumerize(:image_present_choices).in(:all_messages, :half_of_the_messages, :no_messages).with_default(:no_messages) }

  it 'validates number_of_cycles as an integer' do
    message_generation_parameter_set = build(:message_generation_parameter_set, :number_of_cycles => 5.3)

    expect(message_generation_parameter_set.valid?).to be false
  end

  it 'validates number_of_cycles as greater than 0' do
    message_generation_parameter_set = build(:message_generation_parameter_set, :number_of_cycles => 0)

    expect(message_generation_parameter_set.valid?).to be false
  end

  it 'validates number_of_messages_per_social_network as an integer' do
    message_generation_parameter_set = build(:message_generation_parameter_set, :number_of_messages_per_social_network => 4.3)

    expect(message_generation_parameter_set.valid?).to be false
  end

  it 'validates period_in days as greater than 0' do
    message_generation_parameter_set = build(:message_generation_parameter_set, :number_of_messages_per_social_network => 0)

    expect(message_generation_parameter_set.valid?).to be false
  end

  it 'validates that at least one social network choice is selected' do
    message_generation_parameter_set = build(:message_generation_parameter_set, :social_network_choices => nil)

    expect(message_generation_parameter_set.valid?).to be false
  end

  it 'returns social network choices as an array of symbols' do
    message_generation_parameter_set = build(:message_generation_parameter_set)
    message_generation_parameter_set.social_network_choices = ['instagram', 'twitter']

    message_generation_parameter_set.save
    message_generation_parameter_set.reload

    expect(message_generation_parameter_set.social_network_choices).to eq([:instagram, :twitter])
  end

  it 'returns medium choices as an array of symbols' do
    message_generation_parameter_set = build(:message_generation_parameter_set)
    message_generation_parameter_set.medium_choices = ['ad', 'organic']

    message_generation_parameter_set.save
    message_generation_parameter_set.reload

    expect(message_generation_parameter_set.medium_choices).to eq([:ad, :organic])
  end

  it 'returns social network choices stripped of the empty string that is inserted by the editing form' do
    message_generation_parameter_set = build(:message_generation_parameter_set)
    message_generation_parameter_set.social_network_choices = ['instagram', 'twitter', ""]

    message_generation_parameter_set.save
    message_generation_parameter_set.reload

    expect(message_generation_parameter_set.social_network_choices).to eq([:instagram, :twitter])
  end

  it 'returns medium choices as an array of symbols stripped of the empty string that is inserted by the editing form' do
    message_generation_parameter_set = build(:message_generation_parameter_set)
    message_generation_parameter_set.medium_choices = ['ad', 'organic', ""]

    message_generation_parameter_set.save
    message_generation_parameter_set.reload

    expect(message_generation_parameter_set.medium_choices).to eq([:ad, :organic])
  end

  describe 'number of generated messages' do
    it 'is calculated correctly for five message templates, 1 social network, 1 medium, no messages with images, 1 cycle and 1 messages per network per day' do
      message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
        m.social_network_choices = ['facebook']
        m.medium_choices = ['ad']
        m.image_present_choices = :no_messages
        m.number_of_cycles = 1
        m.number_of_messages_per_social_network = 1
      end

      # Number of social networks (1) * Number of mediums (1) * Number of message templates (5) * Number of cycles (1)
      expect(message_generation_parameter_set.expected_generated_message_count(5)).to eq(1 * 1 * 5 * 1)
    end

    it 'is calculated correctly for nine message templates, 1 social network, 1 medium, with half of the messages having images, 1 cycle and 3 messages per network per day' do
      message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
        m.social_network_choices = ['facebook']
        m.medium_choices = ['ad']
        m.image_present_choices = :half_of_the_messages
        m.number_of_cycles = 1
        m.number_of_messages_per_social_network = 3
      end

      # Number of social networks (1) * Number of mediums (1) * Number of message templates (9) * Number of cycles (1)
      expect(message_generation_parameter_set.expected_generated_message_count(9)).to eq(1 * 1 * 9 * 1)
    end

    it 'is calculated correctly when the parameters include one website, nine message templates, 3 social networks, 2 mediums, with all messages having images, for 3 cycles and 3 messages per network per day' do
      message_generation_parameter_set = MessageGenerationParameterSet.new(
        social_network_choices: ['facebook', 'twitter', 'instagram'],
        medium_choices: ['ad', 'organic'],
        image_present_choices: :all_messages,
        number_of_cycles: 3,
        number_of_messages_per_social_network: 3
      )

      # Number of social networks (3) * Number of mediums (2) * Number of message templates (9) * Number of cycles (3) - (Number of message templates (9) * Number of cycles (3))
      # Instagram organic messages are NOT generated, so the count accounts for that
      expect(message_generation_parameter_set.expected_generated_message_count(9)).to eq(3 * 2 * 9 * 3 - (9 * 3))
    end

    it 'is calculated correctly given a set of calculation parameters' do
      calculation_parameters = {}
      calculation_parameters[:social_network_choices_count] = 2
      calculation_parameters[:medium_choices_count] = 3
      calculation_parameters[:number_of_message_templates] = 4
      calculation_parameters[:number_of_cycles] = 5

      expect(MessageGenerationParameterSet.calculate_message_count(calculation_parameters)).to eq(calculation_parameters[:social_network_choices_count] * calculation_parameters[:medium_choices_count] * calculation_parameters[:number_of_message_templates] * calculation_parameters[:number_of_cycles])
    end

    it 'correctly removes the count of the instagram organic messages given a set of calculation parameters which indicates that instagram organic has been selected' do
      calculation_parameters = {}
      calculation_parameters[:social_network_choices_count] = 2
      calculation_parameters[:medium_choices_count] = 3
      calculation_parameters[:number_of_message_templates] = 4
      calculation_parameters[:number_of_cycles] = 5
      calculation_parameters[:instagram_organic] = true

      expect(MessageGenerationParameterSet.calculate_message_count(calculation_parameters)).to eq(calculation_parameters[:social_network_choices_count] * calculation_parameters[:medium_choices_count] * calculation_parameters[:number_of_message_templates] * calculation_parameters[:number_of_cycles] - (calculation_parameters[:number_of_message_templates] * calculation_parameters[:number_of_cycles]))
    end

    it 'returns noncalculable when the number of message templates is not passed in' do
      message_generation_parameter_set = MessageGenerationParameterSet.new

      expect(message_generation_parameter_set.expected_generated_message_count).to eq('Noncalculable')
    end

    it 'returns noncalculable when any of the calculation parameters are nil' do
      calculation_parameters = {}
      calculation_parameters[:social_network_choices_count] = nil
      calculation_parameters[:medium_choices_count] = nil
      calculation_parameters[:number_of_message_templates] = nil
      calculation_parameters[:number_of_cycles] = nil

      expect(MessageGenerationParameterSet.calculate_message_count(calculation_parameters)).to eq('Noncalculable')
    end

    it 'calculates the length of the experiment in days' do
      message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
        m.number_of_cycles = 2
        m.number_of_messages_per_social_network = 3
      end

      # Length of experiment in days = Number of cycles (2) * Number of message templates (6) / Messages per social network per day (3)
      expect(message_generation_parameter_set.length_of_experiment_in_days(6)).to eq(2 * 6 / 3)
    end
  end
end
