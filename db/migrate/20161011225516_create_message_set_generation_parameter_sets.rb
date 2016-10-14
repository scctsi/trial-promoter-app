class CreateMessageSetGenerationParameterSets < ActiveRecord::Migration
  def change
    create_table :message_set_generation_parameter_sets do |t|
      t.string :promoted_websites_tag
      t.string :promoted_clinical_trials_tag
      t.string :promoted_properties_cycle_type
      t.string :selected_message_templates_tag
      t.string :selected_message_templates_cycle_type
      t.string :medium_cycle_type
      t.string :social_network_cycle_type
      t.string :image_present_cycle_type
      t.integer :period_in_days
      t.integer :number_of_messages_per_social_network
      t.references :experiment

      t.timestamps null: false
    end
  end
end
