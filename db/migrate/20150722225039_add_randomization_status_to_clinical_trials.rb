class AddRandomizationStatusToClinicalTrials < ActiveRecord::Migration
  def change
    add_column :clinical_trials, :randomization_status, :string # Selected, Control, Unused
  end
end
