class AddHashtagsToClinicalTrials < ActiveRecord::Migration
  def change
    add_column :clinical_trials, :hashtags, :text
  end
end
