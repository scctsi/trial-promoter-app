class CreateDataDictionaryEntries < ActiveRecord::Migration
  def change
    create_table :data_dictionary_entries do |t|
      t.boolean :include_in_report
      t.string :trial_promoter_label
      t.string :report_label
      t.string :integrity_check
      t.string :source
      t.text :note
      t.references :data_dictionary
      
      t.timestamps null: false
    end
  end
end
