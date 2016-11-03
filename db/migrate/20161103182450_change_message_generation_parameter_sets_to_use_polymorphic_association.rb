class ChangeMessageGenerationParameterSetsToUsePolymorphicAssociation < ActiveRecord::Migration
  def change
    add_reference :message_generation_parameter_sets, :message_generating, polymorphic: true
    remove_column :message_generation_parameter_sets, :experiment_id
    add_index :message_generation_parameter_sets, [:message_generating_type, :message_generating_id], name: 'index_on_message_generating_type_and_message_generating_id'
  end
end
