class ChangeLabelToVariableName < ActiveRecord::Migration
  def change
    rename_column :data_dictionary_entries, :label, :variable_name
  end
end