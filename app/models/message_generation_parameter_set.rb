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
  serialize :social_network_choices
  serialize :medium_choices
  serialize :image_present_choices

  validates :period_in_days, presence: true
  validates :period_in_days, numericality: { only_integer: true, greater_than: 0 }
  validates :number_of_messages_per_social_network, presence: true
  validates :number_of_messages_per_social_network, numericality: { only_integer: true, greater_than: 0 }
  validates :message_generating, presence: true

  enumerize :social_network_distribution, in: [:equal, :random], default: :equal
  enumerize :medium_distribution, in: [:equal, :random], default: :equal
  enumerize :image_present_distribution, in: [:equal, :random], default: :equal

  belongs_to :message_generating, polymorphic: true

  def social_network_choices
    return symbolize_array_items(self[:social_network_choices])
  end

  def medium_choices
    return symbolize_array_items(self[:medium_choices])
  end

  def image_present_choices
    return symbolize_array_items(self[:image_present_choices])
  end

  def expected_generated_message_count
    calculated_count = 1

    #  Number of social networks
    calculated_count *= social_network_choices.select { |network| !network.blank? }.count
    # Number of mediums
    calculated_count *= medium_choices.select { |medium| !medium.blank? }.count
    # NOTE: Images are distributed equally among the messages that are generated. Unlike social networks and mediums, new messages are not generated to get an equal or random distribution of messages containing images.
    # Period in days
    calculated_count *= period_in_days
    # Number of messages per social network
    calculated_count *= number_of_messages_per_social_network

    return calculated_count
  end
  
  private
  
  def symbolize_array_items(array)
    # Convert an array of strings to an array of symbols, removing any blank string first
    # Remove any blank string first.
    return array.select{ |item| !item.blank? }.map{ |item| item.to_sym } if !array.nil?
    nil
  end
end
