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

class MessageGenerationParameterSet < ActiveRecord::Base
  extend Enumerize

  validates :selected_message_templates_tag, presence: true
  validates :period_in_days, presence: true
  validates :number_of_messages_per_social_network, presence: true
  validates :message_generating, presence: true
  
  enumerize :promoted_properties_cycle_type, in: [:all, :random], default: :all
  enumerize :selected_message_templates_cycle_type, in: [:all, :random], default: :all
  enumerize :social_network_cycle_type, in: [:all, :subset], default: :all
  enumerize :medium_cycle_type, in: [:all, :random, :subset], default: :all
  enumerize :image_present_cycle_type, in: [:all, :random, :subset], default: :all

  belongs_to :message_generating, polymorphic: true
  
  def expected_message_set_count
    calculated_count = 1
    
    promoted_website_set = Website.tagged_with(promoted_websites_tag)
    selected_message_template_set = MessageTemplate.tagged_with(selected_message_templates_tag)
    
    # Number of promoted properties (websites + clinical trials)
    calculated_count *= promoted_website_set.count
    # Number of message templates
    calculated_count *= selected_message_template_set.count
    #  Number of social networks
    calculated_count *= SocialNetworks::SUPPORTED_NETWORKS.count if social_network_cycle_type == :all
    # Number of mediums
    calculated_count *= 2 if medium_cycle_type == :all
    calculated_count *= 1 if medium_cycle_type == :random
    # Image/No Image
    calculated_count *= 2 if image_present_cycle_type == :all
    calculated_count *= 1 if image_present_cycle_type == :random
    # Period in days
    calculated_count *= period_in_days
    # Number of messages per social network
    calculated_count *= number_of_messages_per_social_network

    return calculated_count
  end
end
