require 'rails_helper'
require 'httparty'

RSpec.describe TwitterAdsClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:twitter).and_return(secrets['twitter'])
    @twitter_ads_client = TwitterAdsClient.new(true)
    # campaign = nil
    VCR.use_cassette 'twitter_ads_client/test_setup' do
      @account = @twitter_ads_client.get_account.first
    end
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'gets the account' do
      expect(@account.id).to include("gq1azc")
      expect(@account.name).to include("Sandbox account for @USCTrials")
    end
  
    it 'gets any campaigns associated with the ad account' do
      VCR.use_cassette 'twitter_ads_client/get_campaigns' do
        @campaigns = @twitter_ads_client.get_campaigns(@account.id)

        expect(@campaigns.count).to be(115)
      end
    end
      
    it 'creates a campaign associated with the ad account' do
      VCR.use_cassette 'twitter_ads_client/create_campaign' do
        campaign_params = {
          total_budget_amount_local_micro: 1_000_000_000,
          daily_budget_amount_local_micro: 1_000_000,
          name: 'my first campaign',
          entity_status: 'ACTIVE',
          start_time: Time.new(2018, 2, 6, 2, 2, "+00:00")
        }
        
        campaign = @twitter_ads_client.create_campaign(@account, campaign_params)
        
        expect(campaign.id).to include("hqbn")
        expect(campaign.name).to include("my first campaign")
        expect(campaign.entity_status).to include("ACTIVE")
        
        VCR.use_cassette 'twitter_ads_client/create_line_item' do
          line_item_params = {
            name: 'my first objective',
            product_type: 'PROMOTED_TWEETS',
            placements: 'ALL_ON_TWITTER',
            objective: 'AWARENESS',
            bid_type: 'AUTO',
            entity_status: 'ACTIVE'
          }
          
          @line_item = @twitter_ads_client.create_line_item(@account, campaign.id, line_item_params)
        
          expect(@line_item.name).to include("my first objective")
          expect(@line_item.id).to include("ek2k")
        end
        
        VCR.use_cassette 'twitter_ads_client/create_targeting_criteria' do
          targeting_criteria_params = {      
            targeting_type: 'LOCATION',
            location_type: 'REGIONS',
            targeting_value: 'fbd6d2f5a4e4a15e'
          }
          
          @targeting_value = @twitter_ads_client.create_targeting_criteria(@account, @line_item, targeting_criteria_params)
          
          expect(@targeting_value.id).to include("38r08")
        end
      end
    end

    it 'deletes a campaign' do
      VCR.use_cassette 'twitter_ads_client/get_campaigns' do
        @campaigns = @twitter_ads_client.get_campaigns(@account.id)

        expect(@campaigns.count).to be(115)
      end

      VCR.use_cassette 'twitter_ads_client/delete_campaign' do
        @twitter_ads_client.delete_campaign(@campaigns.last)
        campaigns = @twitter_ads_client.get_campaigns(@account.id)
        
        expect(campaigns.count).to eq(114)
      end
    end
    
    it 'gets a campaign' do
      VCR.use_cassette 'twitter_ads_client/get_campaign' do
        campaign_id = "hqac"
        campaign = @twitter_ads_client.get_campaign(@account.id, campaign_id)
        
        expect(campaign.name).to eq('my first campaign')
      end
    end
    
    it 'gets a line_item' do
      VCR.use_cassette 'twitter_ads_client/get_line_item' do
        line_item_id = "ek2g"
        line_item = @twitter_ads_client.get_line_item(@account.id, line_item_id)
        
        expect(line_item.name).to eq('my first objective')
      end
    end
    
    it 'gets targeting_criteria' do
      VCR.use_cassette 'twitter_ads_client/get_targeting_criteria' do
        line_item_id = "ek2g"
        targeting_criteria_id = "38r06"
        targeting_criteria = @twitter_ads_client.get_targeting_criteria(@account.id, line_item_id, targeting_criteria_id)
        
        expect(targeting_criteria.targeting_type).to eq('LOCATION')
      end
    end
    
    it 'updates a campaign' do
      VCR.use_cassette 'twitter_ads_client/update_campaign' do
        campaign_id = "hqbn"
        campaign = @twitter_ads_client.get_campaign(@account.id, campaign_id)
        expect(campaign.entity_status).to eq('ACTIVE')

        @twitter_ads_client.pause_campaign(campaign)
        expect(campaign.entity_status).to eq('PAUSED')
      end      
    end
  end
end