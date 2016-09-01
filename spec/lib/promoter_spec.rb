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

  describe 'picking message templates to use in promotion' do
    before do
      @message_templates = create_list(:message_template, 5, platform: :twitter)
      @message_templates << create_list(:message_template, 5, platform: :facebook)
    end
    
    it 'gets one random message template for one platform' do
      # TODO: How do we test that the templates are randomly selected?
      message_templates_to_use = @promoter.pick_message_templates(1, [:facebook])
      
      expect(message_templates_to_use.count).to eq(1)
      expect(message_templates_to_use[0].facebook?).to be true
    end
    
    it 'gets multiple random message templates for one platform' do
      # TODO: How do we test that the templates are randomly selected?
      message_templates_to_use = @promoter.pick_message_templates(3, [:facebook])
      
      expect(message_templates_to_use.count).to eq(3)
      message_templates_to_use.each do |message_template|
        expect(message_template.facebook?).to be true
      end
    end
    
    it 'gets more random message templates than there are in the database (i.e. it reuses message templates if needed)' do
      # TODO: How do we test that the templates are randomly selected?
      message_templates_to_use = @promoter.pick_message_templates(10, [:facebook])

      expect(message_templates_to_use.count).to eq(10)
      message_templates_to_use.each do |message_template|
        expect(message_template.facebook?).to be true
      end
    end
    
    it 'gets multiple random message templates for multiple platforms' do
      # TODO: How do we test that the templates are randomly selected?
      message_templates_to_use = @promoter.pick_message_templates(10, [:twitter, :facebook])

      expect(message_templates_to_use.count).to eq(20)
      message_templates_to_use.each do |message_template|
        expect(message_template.facebook? || message_template.twitter?).to be true
      end
    end
  end
end