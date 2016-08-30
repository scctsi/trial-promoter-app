require 'rails_helper'

RSpec.describe Promoter do
  before do
    @promoter = Promoter.new
    @clinical_trials = create_list(:clinical_trial, 5)
    @campaigns = create_pair(:campaign)
    @campaigns[0].clinical_trials << @clinical_trials[0]
    @campaigns[0].clinical_trials << @clinical_trials[1]
    @campaigns[1].clinical_trials << @clinical_trials[2]
    @campaigns[0].save
    @campaigns[1].save
  end
  
  describe 'picking clinical trials to promote' do
    it 'picks clinical trials that belong to campaigns and that have never been promoted' do
      clinical_trials_to_promote = @promoter.pick_clinical_trials
      
      expect(clinical_trials_to_promote.count).to eq(3)
      clinical_trials_to_promote.each do |clinical_trial|
        expect(clinical_trial.last_promoted_at).to be_nil
        expect(clinical_trial.campaigns.count).to eq(1)
      end
    end

    it 'orders clinical trials by the time they were last promoted (most recently promoted last)' do
      @clinical_trials[0].last_promoted_at = DateTime.now
      @clinical_trials[1].last_promoted_at = DateTime.now - 1.day
      @clinical_trials[2].last_promoted_at = DateTime.now - 2.days
      @clinical_trials[0].save
      @clinical_trials[1].save
      @clinical_trials[2].save

      clinical_trials_to_promote = @promoter.pick_clinical_trials
      
      expect(clinical_trials_to_promote.count).to eq(3)
      expect(clinical_trials_to_promote[0].last_promoted_at).to be < clinical_trials_to_promote[1].last_promoted_at
      expect(clinical_trials_to_promote[1].last_promoted_at).to be < clinical_trials_to_promote[2].last_promoted_at
    end
    
    it 'ignores clinical trials belonging to any campaign that has not yet started' do
      @campaigns[0].start_date = DateTime.now + 1.day
      @campaigns[0].save

      clinical_trials_to_promote = @promoter.pick_clinical_trials

      expect(clinical_trials_to_promote.count).to eq(1)
      clinical_trials_to_promote.each do |clinical_trial|
        clinical_trial.campaigns.each do |campaign|
          expect(campaign.start_date).to <= DateTime.now if (!campaign.start_date.nil?)
        end
      end
    end

    it 'ignores clinical trials belonging to any campaign that has ended' do
      @campaigns[1].end_date = DateTime.now - 1.day
      @campaigns[1].save

      clinical_trials_to_promote = @promoter.pick_clinical_trials

      expect(clinical_trials_to_promote.count).to eq(2)
      clinical_trials_to_promote.each do |clinical_trial|
        clinical_trial.campaigns.each do |campaign|
          expect(campaign.end_date).to >= DateTime.now if (!campaign.end_date.nil?)
        end
      end
    end
  end
end