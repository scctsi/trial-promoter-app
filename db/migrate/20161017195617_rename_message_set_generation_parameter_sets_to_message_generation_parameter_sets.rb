class RenameMessageSetGenerationParameterSetsToMessageGenerationParameterSets < ActiveRecord::Migration
  def change
    rename_table :message_set_generation_parameter_sets, :message_generation_parameter_sets
  end
end
