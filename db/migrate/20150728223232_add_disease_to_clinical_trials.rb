class AddDiseaseToClinicalTrials < ActiveRecord::Migration
  def change
    add_column :clinical_trials, :disease, :string
  end
end
