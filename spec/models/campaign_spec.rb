require 'rails_helper'

RSpec.describe Campaign, type: :model do
  it { is_expected.to validate_presence_of :name }
  
  it { is_expected.to have_and_belong_to_many(:clinical_trials) }
  
  describe 'current scope' do
    before do
      @campaigns = create_list(:campaign, 5, start_date: nil, end_date: nil)
    end
    
    it 'returns all campaigns with nil start and end dates' do
      current_campaigns = Campaign.current
      
      expect(current_campaigns.count).to eq(5)
    end

    it 'returns all campaigns with start dates in the past and end dates in the future' do
      @campaigns.each do |campaign|
        campaign.start_date = DateTime.now - 1.day
        campaign.end_date = DateTime.now + 1.day
        campaign.save
      end
      
      current_campaigns = Campaign.current
      
      expect(current_campaigns.count).to eq(5)
    end

    it 'excludes any campaign that has not yet started' do
      @campaigns.each do |campaign|
        campaign.start_date = DateTime.now - 1.day
        campaign.save
      end
      @campaigns[4].start_date = DateTime.now + 1.day
      @campaigns[4].save

      current_campaigns = Campaign.current
      
      expect(current_campaigns.count).to eq(4)
      current_campaigns.each do |campaign|
        expect(campaign.start_date).to be < DateTime.now
      end
    end

    it 'excludes any campaign that has ended' do
      @campaigns.each do |campaign|
        campaign.end_date = DateTime.now + 1.day
        campaign.save
      end
      @campaigns[4].end_date = DateTime.now - 1.day
      @campaigns[4].save

      current_campaigns = Campaign.current
      
      expect(current_campaigns.count).to eq(4)
      current_campaigns.each do |campaign|
        expect(campaign.end_date).to be > DateTime.now
      end
    end
  end
end
