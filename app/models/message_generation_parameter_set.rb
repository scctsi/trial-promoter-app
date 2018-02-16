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
#  message_run_duration_in_days          :integer
#

class MessageGenerationParameterSet < ActiveRecord::Base
  extend Enumerize
  serialize :social_network_choices, Array
  serialize :medium_choices, Array

  validates :number_of_cycles, presence: true
  validates :number_of_cycles, numericality: { only_integer: true, greater_than: 0 }
  validates :number_of_messages_per_social_network, presence: true
  validates :number_of_messages_per_social_network, numericality: { only_integer: true, greater_than: 0 }
  validates :social_network_choices, presence: true
  validates :medium_choices, presence: true
  validates :image_present_choices, presence: true
  enumerize :image_present_choices, in: [:all_messages, :half_of_the_messages, :no_messages], default: :no_messages
  validates :message_generating, presence: true

  belongs_to :message_generating, polymorphic: true

  def social_network_choices
    return symbolize_array_items(self[:social_network_choices])
  end

  def medium_choices
    return symbolize_array_items(self[:medium_choices])
  end

  def expected_generated_message_count(number_of_message_templates = nil)
    return 'Noncalculable' if number_of_message_templates.nil?

    # Number of social networks (1) * Number of mediums (1) * (Number of message templates (9) / Number of messages per social network (3)) * Number of cycles
    calculation_parameters = {}

    calculation_parameters[:social_network_choices_count] = social_network_choices.select { |network| !network.blank? }.count
    calculation_parameters[:medium_choices_count] = medium_choices.select { |medium| !medium.blank? }.count
    calculation_parameters[:number_of_message_templates] = number_of_message_templates
    calculation_parameters[:number_of_cycles] = number_of_cycles
    if social_network_choices.include?(:instagram) && medium_choices.include?(:organic)
      calculation_parameters[:instagram_organic] = true
    else
      calculation_parameters[:instagram_organic] = false
    end

    MessageGenerationParameterSet.calculate_message_count(calculation_parameters)
  end

  def self.calculate_message_count(calculation_parameters)
    return 'Noncalculable' if calculation_parameters[:social_network_choices_count].nil? || calculation_parameters[:medium_choices_count].nil? || calculation_parameters[:number_of_message_templates].nil? || calculation_parameters[:number_of_cycles].nil?

    calculated_count = calculation_parameters[:social_network_choices_count] * calculation_parameters[:medium_choices_count] * calculation_parameters[:number_of_message_templates] * calculation_parameters[:number_of_cycles]
    calculated_count -= (calculation_parameters[:number_of_message_templates] * calculation_parameters[:number_of_cycles]) if calculation_parameters[:instagram_organic]
    calculated_count
  end

  def length_of_experiment_in_days(number_of_message_templates)
    number_of_cycles * number_of_message_templates / number_of_messages_per_social_network
  end
end
