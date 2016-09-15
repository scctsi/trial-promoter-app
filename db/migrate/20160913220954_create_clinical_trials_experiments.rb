class CreateClinicalTrialsExperiments < ActiveRecord::Migration
  def change
    create_table :clinical_trials_experiments do |t|
      t.belongs_to :experiment, index: true
      t.belongs_to :clinical_trial, index: true
    end
  end
end