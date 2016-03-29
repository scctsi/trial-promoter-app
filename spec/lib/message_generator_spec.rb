require 'rails_helper'

RSpec.describe MessageGenerator do
  before do
    @message_generator = MessageGenerator.new
  end
  
  describe "finding clinical trials that need to be promoted" do
    it "finds clinical trials that have never been promoted" do
      unpromoted_clinical_trials = create_list(:clinical_trial, 3)
      
      clinical_trials_needing_promotion = @message_generator.get_trials_needing_promotion
      
      expect(clinical_trials_needing_promotion.length).to eq(unpromoted_clinical_trials.length)
    end
    
    it "only returns the trials that have never been promoted if there are some trials that have already been promoted" do
      unpromoted_clinical_trials = create_list(:clinical_trial, 3)
      create_list(:clinical_trial, 3, :last_promoted_at => DateTime.now)
      
      clinical_trials_needing_promotion = @message_generator.get_trials_needing_promotion

      expect(clinical_trials_needing_promotion.length).to eq(unpromoted_clinical_trials.length)
      clinical_trials_needing_promotion.each do |clinical_trial|
        expect(clinical_trial.last_promoted_at).to be_nil
      end
    end
    
    it "returns the trials sorted by the chronological order in which they were promoted if all trials have already been promoted at least once" do
      (0..2).each do |offset|
        # I'm using the offset to change the last_promoted_at time when creating a clinical trial.
        # However I'm storing the clinical trials in reverse chronological order.
        # This ensures that we cannot just return all the clinical trials in the order that the database has stored them.
        create(:clinical_trial, :last_promoted_at => DateTime.now + (2 - offset))
      end

      clinical_trials_needing_promotion = @message_generator.get_trials_needing_promotion
      
      ordered_clinical_trials = ClinicalTrial.all.to_a.sort { |a,b| a.last_promoted_at <=> b.last_promoted_at }
      expect(clinical_trials_needing_promotion).to eq(ordered_clinical_trials)
    end
  end
end