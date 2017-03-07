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
  validates :message_generating, presence: true
  enumerize :image_present_choices, in: [:all_messages, :half_of_the_messages, :no_messages], default: :no_messages

  belongs_to :message_generating, polymorphic: true

  def social_network_choices
    return symbolize_array_items(self[:social_network_choices])
  end

  def medium_choices
    return symbolize_array_items(self[:medium_choices])
  end

  def expected_generated_message_count(number_of_message_templates)
    # Number of social networks (1) * Number of mediums (1) * (Number of message templates (9) / Number of messages per social network (3)) * Number of cycles
    calculation_parameters = {}
    
    calculation_parameters[:social_network_choices_count] = social_network_choices.select { |network| !network.blank? }.count
    calculation_parameters[:medium_choices_count] = medium_choices.select { |medium| !medium.blank? }.count
    calculation_parameters[:number_of_message_templates] = number_of_message_templates
    calculation_parameters[:number_of_cycles] = number_of_cycles

    MessageGenerationParameterSet.calculate_message_count(calculation_parameters)
  end

  def self.calculate_message_count(calculation_parameters)
    calculation_parameters[:social_network_choices_count] * calculation_parameters[:medium_choices_count] * calculation_parameters[:number_of_message_templates] * calculation_parameters[:number_of_cycles]
  end
end
