# == Schema Information
#
# Table name: message_generation_parameter_sets
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

class MessageGenerationParameterSet < ActiveRecord::Base
  extend Enumerize
  serialize :social_network_choices
  serialize :medium_choices
  serialize :image_choices

  validates :period_in_days, presence: true
  validates :number_of_messages_per_social_network, presence: true
  validates :message_generating, presence: true
  
  enumerize :social_network_distribution, in: [:equal, :random], default: :equal
  enumerize :medium_distribution, in: [:equal, :random], default: :equal
  enumerize :image_present_distribution, in: [:equal, :random], default: :equal

  belongs_to :message_generating, polymorphic: true
  
  def expected_generated_message_count
    calculated_count = 1
    
    promoted_websites = Website.tagged_with(promoted_websites_tag)
    selected_message_templates = MessageTemplate.tagged_with(selected_message_templates_tag)
    
    # Number of promoted properties (websites + clinical trials)
    calculated_count *= promoted_websites.count
    # Number of message templates
    calculated_count *= selected_message_templates.count
    #  Number of social networks
    calculated_count *= SocialNetworks::SUPPORTED_NETWORKS.count if social_network_distribution == :all
    # Number of mediums
    calculated_count *= 2 if medium_distribution == :all
    calculated_count *= 1 if medium_distribution == :random
    # Image/No Image
    calculated_count *= 2 if image_present_distribution == :all
    calculated_count *= 1 if image_present_distribution == :random
    # Period in days
    calculated_count *= period_in_days
    # Number of messages per social network
    calculated_count *= number_of_messages_per_social_network

    return calculated_count
  end
end
