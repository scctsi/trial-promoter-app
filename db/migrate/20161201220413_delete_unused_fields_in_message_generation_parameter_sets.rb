class DeleteUnusedFieldsInMessageGenerationParameterSets < ActiveRecord::Migration
  def up
    remove_column :message_generation_parameter_sets, :promoted_websites_tag
    remove_column :message_generation_parameter_sets, :promoted_clinical_trials_tag
    remove_column :message_generation_parameter_sets, :promoted_properties_cycle_type
    remove_column :message_generation_parameter_sets, :selected_message_templates_tag
    remove_column :message_generation_parameter_sets, :selected_message_templates_cycle_type
  end
  
  def down
    add_column :message_generation_parameter_sets, :promoted_websites_tag, :string
    add_column :message_generation_parameter_sets, :promoted_clinical_trials_tag, :string
    add_column :message_generation_parameter_sets, :promoted_properties_cycle_type, :string
    add_column :message_generation_parameter_sets, :selected_message_templates_tag, :string
    add_column :message_generation_parameter_sets, :selected_message_templates_cycle_type, :string
  end
end

