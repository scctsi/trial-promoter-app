class CalculateToxicityScoreJob < ActiveJob::Base
  queue_as :default
 
  def perform
    comments = Comment.all
    
    comments.each do |comment|
      comment.save_toxicity_score
    end
  end
end