class CreateCampaignsClinicalTrials < ActiveRecord::Migration
  def change
    create_table :campaigns_clinical_trials do |t|
      t.belongs_to :campaign, index: true
      t.belongs_to :clinical_trial, index: true
    end
  end
end
