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

class MessageGenerationParameterSet < ActiveRecord::Base
  extend Enumerize
  serialize :social_network_choices
  serialize :medium_choices
  serialize :image_present_choices

  validates :period_in_days, presence: true
  validates :number_of_messages_per_social_network, presence: true
  validates :message_generating, presence: true
  
  enumerize :social_network_distribution, in: [:equal, :random], default: :equal
  enumerize :medium_distribution, in: [:equal, :random], default: :equal
  enumerize :image_present_distribution, in: [:equal, :random], default: :equal

  belongs_to :message_generating, polymorphic: true
  
  def expected_generated_message_count
    calculated_count = 1
    
    #  Number of social networks
    calculated_count *= social_network_choices.select { |network| !network.blank? }.count
    # Number of mediums
    calculated_count *= medium_choices.select { |medium| !medium.blank? }.count
    # With/without images
    calculated_count *= image_present_choices.select { |image_present| !image_present.blank? }.count
    # Period in days
    calculated_count *= period_in_days
    # Number of messages per social network
    calculated_count *= number_of_messages_per_social_network

    return calculated_count
  end
end
