class AddChoicesForSocialNetworkMediumAndImagesToMessageGenerationParameterSets < ActiveRecord::Migration
  def change
    add_column :message_generation_parameter_sets, :social_network_choices, :text
    add_column :message_generation_parameter_sets, :medium_choices, :text
    add_column :message_generation_parameter_sets, :image_choices, :text
  end
end
