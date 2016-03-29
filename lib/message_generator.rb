class MessageGenerator
  def get_trials_needing_promotion
    clinical_trials = ClinicalTrial.where(last_promoted_at: nil)
    
    if clinical_trials.length == 0
      clinical_trials = ClinicalTrial.order(:last_promoted_at)
    end
    
    clinical_trials
  end
end