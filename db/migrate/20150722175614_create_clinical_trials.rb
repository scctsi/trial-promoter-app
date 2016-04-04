class CreateClinicalTrials < ActiveRecord::Migration
  def change
    create_table :clinical_trials do |t|
      t.string :title, :limit => 1000
      t.string :pi_name
      t.string :url, :limit => 2000
      t.string :nct_id
      t.string :initial_database_id

      t.timestamps
    end
  end
end
