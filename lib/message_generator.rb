class MessageGenerator
  def get_trials_needing_promotion
    clinical_trials = ClinicalTrial.where(last_promoted_at: nil)
    
    if clinical_trials.length == 0
      clinical_trials = ClinicalTrial.order(:last_promoted_at)
    end
    
    clinical_trials
  end
  
  def create_promotion_messages(trials, message_templates)
    messages = []
    
    trials.each do |trial|
      messages << message_templates.sample(1).generate_message(trial)
    end
    
    # Save all the messages
    messages.each do |message|
      message.save
    end
    
    messages
  end
end