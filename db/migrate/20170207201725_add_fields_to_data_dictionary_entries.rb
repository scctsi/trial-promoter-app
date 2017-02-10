class AddFieldsToDataDictionaryEntries < ActiveRecord::Migration
  def change
    add_column :data_dictionary_entries, :allowed_values, :text
    add_column :data_dictionary_entries, :value_mapping, :text
  end
end
