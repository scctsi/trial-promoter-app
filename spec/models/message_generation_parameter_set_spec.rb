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
#  image_present_choices                 :text
#

require 'rails_helper'

describe MessageGenerationParameterSet do
  it { is_expected.to validate_presence_of :number_of_cycles }
  it { is_expected.to validate_presence_of :number_of_messages_per_social_network }
  it { is_expected.to validate_presence_of :message_generating }
  it { is_expected.to belong_to(:message_generating) }

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

  it 'stores an array of social network choices' do
    message_generation_parameter_set = build(:message_generation_parameter_set)
    message_generation_parameter_set.social_network_choices = [:instagram, :twitter]

    message_generation_parameter_set.save
    message_generation_parameter_set.reload

    expect(message_generation_parameter_set.social_network_choices).to eq([:instagram, :twitter])
  end

  it 'stores an array of medium choices' do
    message_generation_parameter_set = build(:message_generation_parameter_set)
    message_generation_parameter_set.medium_choices = [:ad, :organic]

    message_generation_parameter_set.save
    message_generation_parameter_set.reload

    expect(message_generation_parameter_set.medium_choices).to eq([:ad, :organic])
  end

  it 'stores an array of image choices' do
    message_generation_parameter_set = build(:message_generation_parameter_set)
    message_generation_parameter_set.image_present_choices = [:with, :without]

    message_generation_parameter_set.save
    message_generation_parameter_set.reload

    expect(message_generation_parameter_set.image_present_choices).to eq([:with, :without])
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

  it 'returns image choices as an array of symbols' do
    message_generation_parameter_set = build(:message_generation_parameter_set)
    message_generation_parameter_set.image_present_choices = ['with', 'without']

    message_generation_parameter_set.save
    message_generation_parameter_set.reload

    expect(message_generation_parameter_set.image_present_choices).to eq([:with, :without])
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

  it 'returns image choices as an array of symbols stripped of the empty string that is inserted by the editing form' do
    message_generation_parameter_set = build(:message_generation_parameter_set)
    message_generation_parameter_set.image_present_choices = ['with', 'without', ""]

    message_generation_parameter_set.save
    message_generation_parameter_set.reload

    expect(message_generation_parameter_set.image_present_choices).to eq([:with, :without])
  end

  describe 'number of generated messages' do
    it 'is calculated correctly when the parameters include one website, five message templates, 1 social network (equal distribution), 1 medium (equal distribution), with images (equal distribution), for 10 days and 3 messages per network per day' do
      message_generation_parameter_set = MessageGenerationParameterSet.new do |m|
        m.social_network_choices = ['facebook']
        m.medium_choices = ['ad']
        m.image_present_choices = ['with']
        m.period_in_days = 10
        m.number_of_messages_per_social_network = 3
      end

      # Number of social networks (1) * Number of mediums (1) * Number of image present choices (1) * Period in days(10) * Number of messages per social network (3)
      expect(message_generation_parameter_set.expected_generated_message_count).to eq(1 * 1 * 1 * 10 * 3)
    end

    it 'is calculated correctly when the parameters include one website, five message templates, 3 social networks (equal distribution), 2 mediums (equal distribution), with and without images (equal distribution), for 10 days and 3 messages per network per day' do
      message_generation_parameter_set = MessageGenerationParameterSet.new(
        social_network_choices: ['facebook', 'twitter', 'instagram'],
        medium_choices: ['ad', 'organic'],
        image_present_choices: ['with', 'without'],
        period_in_days: 10,
        number_of_messages_per_social_network: 3
      )

      # Number of social networks (3) * Number of mediums (2) * Period in days(10) * Number of messages per social network (3)
      expect(message_generation_parameter_set.expected_generated_message_count).to eq(3 * 2 * 1 * 10 * 3)
    end

    it 'calculates the number of messages' do
      expect(MessageGenerationParameterSet.calculate_message_count(2, 3, 4, 5)).to eq(2 * 3 * 4 * 5)
    end
  end
end
