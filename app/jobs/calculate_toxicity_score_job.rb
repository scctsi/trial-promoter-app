class CalculateToxicityScoreJob < ActiveJob::Base
  queue_as :default
 
  def perform(experiment)
    comments = Comment.all
    
    comments.each do |comment|
      comment.save_toxicity_score(experiment)
    end
  end
end