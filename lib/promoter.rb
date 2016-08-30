class Promoter
  def pick_clinical_trials
    current_campaign_ids = Campaign.where('start_date <= ? or start_date is null', DateTime.now).pluck(:id)
    clinical_trials = ClinicalTrial.joins('join campaigns_clinical_trials on clinical_trials.id = campaigns_clinical_trials.clinical_trial_id').where('campaigns_clinical_trials.campaign_id is not null and campaigns_clinical_trials.campaign_id in ' + '(' + current_campaign_ids.join(',') + ')').order(last_promoted_at: :asc)

    return clinical_trials
  end
end