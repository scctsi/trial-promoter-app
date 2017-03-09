class ModifyMessageGenerationParameterSetFields < ActiveRecord::Migration
  def change
    remove_column :message_generation_parameter_sets, :medium_distribution, :string
    remove_column :message_generation_parameter_sets, :social_network_distribution, :string
    remove_column :message_generation_parameter_sets, :image_present_distribution, :string
    
    add_column :message_generation_parameter_sets, :number_of_cycles, :integer
  end
end

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
