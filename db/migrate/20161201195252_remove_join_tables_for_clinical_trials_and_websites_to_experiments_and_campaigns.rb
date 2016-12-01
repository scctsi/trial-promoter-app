class RemoveJoinTablesForClinicalTrialsAndWebsitesToExperimentsAndCampaigns < ActiveRecord::Migration
  def change
    drop_table :campaigns_clinical_trials
    drop_table :clinical_trials_experiments
    drop_table :experiments_websites
  end
end