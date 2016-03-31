require 'rails_helper'

RSpec.describe MessageGenerator do
  before do
    @message_generator = MessageGenerator.new
  end
  
  describe "finding clinical trials that need to be promoted" do
    it "finds clinical trials that have never been promoted" do
      unpromoted_trials = create_list(:clinical_trial, 3)
      
      trials_needing_promotion = @message_generator.get_trials_needing_promotion
      
      expect(trials_needing_promotion.length).to eq(unpromoted_trials.length)
    end
    
    it "only returns the trials that have never been promoted if there are some trials that have already been promoted" do
      unpromoted_trials = create_list(:clinical_trial, 3)
      create_list(:clinical_trial, 3, :last_promoted_at => DateTime.now)
      
      trials_needing_promotion = @message_generator.get_trials_needing_promotion

      expect(trials_needing_promotion.length).to eq(unpromoted_trials.length)
      trials_needing_promotion.each do |trial|
        expect(trial.last_promoted_at).to be_nil
      end
    end
    
    it "returns the trials sorted by the chronological order in which they were promoted if all trials have already been promoted at least once" do
      (0..2).each do |offset|
        # I'm using the offset to change the last_promoted_at time when creating a clinical trial.
        # However I'm storing the clinical trials in reverse chronological order.
        # This ensures that we cannot just return all the clinical trials in the order that the database has stored them.
        create(:clinical_trial, :last_promoted_at => DateTime.now + (2 - offset))
      end

      trials_needing_promotion = @message_generator.get_trials_needing_promotion
      
      ordered_trials = ClinicalTrial.all.to_a.sort { |a,b| a.last_promoted_at <=> b.last_promoted_at }
      expect(trials_needing_promotion).to eq(ordered_trials)
    end
  end
  
  describe "creating a set of promotion messages" do
    # TODO: This test relies on a lot of test doubles, look into cleaning this up.
    before do
      @trials_needing_promotion = build_list(:clinical_trial, 3)
      @message_templates = build_list(:message_template, 5)
      # Return the same set of message templates each time even when using sample, so that we can test message generation
      allow(@message_templates).to receive(:sample).and_return(@message_templates[0], @message_templates[1], @message_templates[0])
      @messages = build_list(:message, 5)
      (0..4).each do |index|
        allow(@message_templates[index]).to receive(:generate_message).and_return(@messages[index])
      end
    end
    
    it "creates one saved message for each trial needing promotion using a random message template for each trial" do
      promotion_messages = @message_generator.create_promotion_messages(@trials_needing_promotion, @message_templates)
      
      expect(promotion_messages.length).to eq(@trials_needing_promotion.length)
      expect(@message_templates[0]).to have_received(:generate_message).with(@trials_needing_promotion[0])
      expect(@message_templates[1]).to have_received(:generate_message).with(@trials_needing_promotion[1])
      expect(@message_templates[0]).to have_received(:generate_message).with(@trials_needing_promotion[2])
      expect(promotion_messages[0]).to eq(@messages[0])
      expect(promotion_messages[1]).to eq(@messages[1])
      expect(promotion_messages[2]).to eq(@messages[0])
      promotion_messages.each do |promotion_message|
        expect(promotion_message.persisted?).to be_truthy
      end
    end
  end
end