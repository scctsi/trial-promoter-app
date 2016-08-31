class Promoter
  def pick_clinical_trials
    current_campaign_ids = Campaign.current.pluck(:id)
    clinical_trials = ClinicalTrial.joins('join campaigns_clinical_trials on clinical_trials.id = campaigns_clinical_trials.clinical_trial_id').where('campaigns_clinical_trials.campaign_id is not null and campaigns_clinical_trials.campaign_id in ' + '(' + current_campaign_ids.join(',') + ')').order(last_promoted_at: :asc)

    return clinical_trials
  end
  
  def pick_message_templates(count, platforms)
    message_templates = []
    
    platforms.each do |platform|
      all_message_templates_in_platform = MessageTemplate.where(platform: platform)
      (1..count).each do 
        message_templates << all_message_templates_in_platform.sample
      end
    end
    
    message_templates
  end
end