require 'rails_helper'
require 'httparty'

RSpec.describe TwitterAdsClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:twitter).and_return(secrets['twitter'])
    @twitter_ads_client = TwitterAdsClient.new(true)
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

        expect(@campaigns.count).to be(125)
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
        
        expect(campaign.id).to include("hqe5")
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
          expect(@line_item.id).to include("ek4x")
        end
        
        VCR.use_cassette 'twitter_ads_client/create_targeting_criteria' do
          targeting_criteria_params = {      
            targeting_type: 'LOCATION',
            location_type: 'REGIONS',
            targeting_value: 'fbd6d2f5a4e4a15e'
          }
          
          @targeting_value = @twitter_ads_client.create_targeting_criteria(@account, @line_item, targeting_criteria_params)
          
          expect(@targeting_value.id).to include("38r18")
        end
      end
    end

    it 'deletes a campaign' do
      VCR.use_cassette 'twitter_ads_client/get_campaigns' do
        @campaigns = @twitter_ads_client.get_campaigns(@account.id)

        expect(@campaigns.count).to be(125)
      end

      VCR.use_cassette 'twitter_ads_client/delete_campaign' do
        campaign = @twitter_ads_client.get_campaign(@account.id, 'hqe2')
        
        @twitter_ads_client.delete_campaign(campaign)
        campaigns = @twitter_ads_client.get_campaigns(@account.id)
        
        expect(campaigns.count).to eq(124)
      end
    end
    
    it 'gets a campaign' do
      VCR.use_cassette 'twitter_ads_client/get_campaign' do
        campaign_id = "hqe3"
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
    
    it 'pauses a campaign' do
      VCR.use_cassette 'twitter_ads_client/pause_campaign' do
        campaign_id = "hqe5"
        campaign = @twitter_ads_client.get_campaign(@account.id, campaign_id)
        expect(campaign.entity_status).to eq('ACTIVE')

        @twitter_ads_client.pause_campaign(campaign)
        expect(campaign.entity_status).to eq('PAUSED')
      end      
    end
    
    describe "run ad account tests on the actual ad account" do
      before do
        @twitter_ads_client = TwitterAdsClient.new(false)
        VCR.use_cassette 'twitter_ads_client/real_setup' do
          @ad_account = @twitter_ads_client.get_account.first
        end
      end
      
      it 'creates an account outside of the sandbox' do
        expect(@ad_account.id).to eq('18ce53zp9m8')
        expect(@ad_account.name).to eq('USC Clinical Trials')
      end

      it 'creates an actual campaign associated with the ad account' do
        VCR.use_cassette 'twitter_ads_client/create_ad_campaign' do
          campaign_params = {
            total_budget_amount_local_micro: 1_000_000_000,
            daily_budget_amount_local_micro: 1_000_000,
            name: 'my first REAL campaign',
            entity_status: 'ACTIVE',
            start_time: Time.new(2018, 2, 8, 2, 2, "+00:00")
          }
          
          campaign = @twitter_ads_client.create_campaign(@ad_account, campaign_params)
          
          expect(campaign.id).to include("ac61o")
          expect(campaign.name).to include("my first REAL campaign")
          expect(campaign.entity_status).to include("ACTIVE")
          
          VCR.use_cassette 'twitter_ads_client/create_ad_line_item' do
            line_item_params = {
              name: 'my first objective',
              product_type: 'PROMOTED_TWEETS',
              placements: 'ALL_ON_TWITTER',
              objective: 'AWARENESS',
              bid_type: 'AUTO',
              entity_status: 'PAUSED'
            }
            
            @line_item = @twitter_ads_client.create_line_item(@ad_account, 'ac5vs', line_item_params)
          
            expect(@line_item.name).to include("my first objective")
            expect(@line_item.id).to include("b0skf")
          end
          
          VCR.use_cassette 'twitter_ads_client/create_ad_targeting_criteria' do
            targeting_criteria_params = {      
            targeting_type: 'LOCATION',
            location_type: 'REGIONS',
            targeting_value: 'fbd6d2f5a4e4a15e'
            }
            
            @targeting_value = @twitter_ads_client.create_targeting_criteria(@ad_account, @line_item, targeting_criteria_params)
            
            expect(@targeting_value.id).to include("hl8uz0")
          end
          
          VCR.use_cassette 'twitter_ads_client/get_actual_ad_campaigns' do
            campaigns = @twitter_ads_client.get_campaigns(@ad_account.id)
          
            expect(campaigns.count).to eq(1)
          end
        end
      end
            
      it 'gets actual campaign' do
        VCR.use_cassette 'twitter_ads_client/get_ad_campaign' do
          campaign_id = "ac5vs"
          campaign = @twitter_ads_client.get_campaign(@ad_account.id, campaign_id)
          
          expect(campaign.name).to eq('Awareness campaign')
        end
      end
      
      it 'gets actual line_item' do
        VCR.use_cassette 'twitter_ads_client/get_ad_line_item' do
          line_item_id = "b0sjz"
          line_item = @twitter_ads_client.get_line_item(@ad_account.id, line_item_id)
          
          expect(line_item.name).to eq('my first objective')
        end
      end
      
      it 'gets actual targeting_criteria' do
        VCR.use_cassette 'twitter_ads_client/get_ad_targeting_criteria' do
          line_item_id = "b0sjz"
          targeting_criteria_id = "hl8tfo"
          targeting_criteria = @twitter_ads_client.get_targeting_criteria(@ad_account.id, line_item_id, targeting_criteria_id)
          
          expect(targeting_criteria.targeting_type).to eq('LOCATION')
        end
      end
          
      it 'deletes any campaigns associated with the ad account' do
        VCR.use_cassette 'twitter_ads_client/get_actual_campaigns_for_deletion' do
          @campaigns = @twitter_ads_client.get_campaigns(@ad_account.id)
  
          expect(@campaigns.count).to be(2)
          
          #delete actual campaigns
          @campaigns.each{ |campaign| @twitter_ads_client.delete_campaign(campaign)}
          
          @campaigns = @twitter_ads_client.get_campaigns(@ad_account.id)
  
          expect(@campaigns.count).to be(0)
        end
      end
          
      it 'promotes an organic tweet to an ad associated with a campaign' do
        VCR.use_cassette 'twitter_ads_client/promote_tweet' do
          #Select a campaign that was created successfully
          #obtained through the 'twitter-ads' cli
          # enter 'twitter-ads' in bash to get the twitter-ads prompt
          # enter 'CLIENT.account.first' in the cli to get the account
          # enter 'CLIENT.account.first.campaigns.first' in the cli to get the campaign
          # enter 'CLIENT.account.first.line_items.first' in the cli to get the line_item
          # campaign = @twitter_ads_client.get_campaigns(@ad_account.id).first
          
          campaign_id = "ac6w5"
          tweet_id = @twitter_ads_client.get_scoped_timeline(@ad_account.id, campaign_id).first[:id]
  
          expect(tweet_id).to eq(822248659043520512)
  
          line_item_id = "b0tgt"
          
          promoted_tweet = @twitter_ads_client.promote_tweet(@ad_account, line_item_id, tweet_id)
  
          expect(promoted_tweet.id).to eq("1qxss9")
        end
      end
      
      it 'pauses the campaign with the promoted tweet' do
        VCR.use_cassette 'twitter_ads_client/pause_ad_campaign' do
          campaign_id = "ac6w5"
          campaign = @twitter_ads_client.get_campaign(@ad_account.id, campaign_id)
          
          expect(campaign.entity_status).to eq('ACTIVE')
          
          @twitter_ads_client.pause_campaign(campaign)
        
          expect(campaign.entity_status).to eq('PAUSED')
        end
      end
    end
  end
end