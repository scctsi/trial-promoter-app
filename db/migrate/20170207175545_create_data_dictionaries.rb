class CreateDataDictionaries < ActiveRecord::Migration
  def change
    create_table :data_dictionaries do |t|
      t.references :experiment
      
      t.timestamps null: false
    end
  end
end
