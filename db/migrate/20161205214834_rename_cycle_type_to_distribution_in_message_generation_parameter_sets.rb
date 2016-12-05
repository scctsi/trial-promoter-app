class RenameCycleTypeToDistributionInMessageGenerationParameterSets < ActiveRecord::Migration
  def change
    rename_column :message_generation_parameter_sets, :social_network_cycle_type, :social_network_distribution
    rename_column :message_generation_parameter_sets, :medium_cycle_type, :medium_distribution
    rename_column :message_generation_parameter_sets, :image_present_cycle_type, :image_present_distribution
  end
end
