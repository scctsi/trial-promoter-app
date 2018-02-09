require 'rails_helper'

RSpec.describe FacebookAdsClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:facebook_ads_access_token).and_return(secrets['facebook_ads_access_token'])
    allow(Setting).to receive(:[]).with(:facebook_app_secret).and_return(secrets['facebook_app_secret'])
    @facebook_ads_client = FacebookAdsClient.new
    @ad_account = @facebook_ads_client.get_account("act_115443465928527")
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'gets the account of Sandbox' do
      expect(@ad_account).not_to be_nil
      expect(@ad_account["id"]).to eq('act_115443465928527')
    end
    
    it 'gets the name of the account' do
      VCR.use_cassette 'facebook_ads_client/get_account_name' do
        # name = @facebook_ads_client.get_account_name(@ad_account)
        expect(@ad_account.name).to eq("New Sandbox Ad Account")
      end
    end

    it 'gets the campaign names associated with an ad account' do
      VCR.use_cassette 'facebook_ads_client/create_campaign' do
        @facebook_ads_client.get_campaign_ids.each{ |campaign| @facebook_ads_client.delete_campaign(campaign) }
        
        expect(@facebook_ads_client.get_campaign_names.count).to eq(0)
        @facebook_ads_client.create_campaign('Healthy Living Campaign') 
        @facebook_ads_client.get_account('act_115443465928527')
        
        expect(@facebook_ads_client.get_campaign_names.count).to eq(1)
        expect(@facebook_ads_client.get_campaign_names).to include('Healthy Living Campaign')
      end
    end
    
    it 'destroys a campaign' do
      VCR.use_cassette 'facebook_ads_client/delete_campaign' do
        @facebook_ads_client.create_campaign("Keep Kalm and Keto On Kampaign")  
        all_campaign_ids = @facebook_ads_client.get_campaign_ids
        
        expect(@facebook_ads_client.get_campaign_names.count).to be > 0
        expect(all_campaign_ids.count).to be > 0
        
        all_campaign_ids.each do |campaign_id|
          @facebook_ads_client.delete_campaign(campaign_id)
        end

        # reload the ad_account 
        @ad_account = @facebook_ads_client.get_account("act_115443465928527")
    
        expect(@facebook_ads_client.get_campaign_names.count).to eq(0)
        expect(@facebook_ads_client.get_campaign_ids.count).to eq(0)
      end
    end
    
    it 'raises an exception if a non-existent campaign' do
      VCR.use_cassette 'facebook_ads_client/delete_campaign' do
      end
    end
    
    it 'gets the campaign ids' do
      VCR.use_cassette 'facebook_ads_client/get_campaign_ids' do
        @facebook_ads_client.get_campaign_ids.each{ |campaign| @facebook_ads_client.delete_campaign(campaign) }
        @ad_account = @facebook_ads_client.get_account("act_115443465928527")
        
        expect(@facebook_ads_client.get_campaign_ids.count).to eq(0)
        
        @facebook_ads_client.create_campaign('Live Long and Prosper Campaign')
        @ad_account = @facebook_ads_client.get_account("act_115443465928527")

        expect(@facebook_ads_client.get_campaign_ids.count).to eq(1)
        expect(@facebook_ads_client.get_campaign_ids[0]).to eq("120330000025682803")
      end
    end
    
    it 'gets the ad sets from a campaign id' do
      VCR.use_cassette 'facebook_ads_client/get_ad_sets' do
      ad_sets =  @facebook_ads_client.get_ad_sets

      expect(ad_sets.count).to eq(1)
      expect(ad_sets[0].name).to eq(:adsets)
      expect(ad_sets[0].node.id).to eq("120330000025682803")
      end
    end
    
    #REF https://developers.facebook.com/docs/marketing-api/reference/ad-campaign
    it 'creates an ad set id' do
      VCR.use_cassette 'facebook_ads_client/create_ad_set' do
        
        
        #TODO Clean this up!!!
        
        
        targeting = {
          geo_locations: {
            countries: ['US']
          }
        }
        bid_amount = 3000
        daily_budget = 15000
        promoted_object = {
          application_id: '135216893922228'
        }
        ad_set = @facebook_ads_client.create_ad_set("Eat More Fat", "120330000025682803", targeting, bid_amount, daily_budget, promoted_object, 'REACH')

        expect(ad_set.id).to eq("120330000025683203")
      end
    end 

    #REF https://developers.facebook.com/docs/marketing-api/reference/ad-campaign/ads/
    it 'creates an ad creative id' do
      VCR.use_cassette 'facebook_ads_client/create_adcreative' do
        name = "Try fasting!"
        object_story_spec = {
          page_id: "641520102717189",
          template_data: {
            additional_image_index: 0,
            call_to_action: { type: 'LEARN_MORE' },
            description: 'Keep your metabolism in check!',
            link: "http://sc-ctsi.org"
          }
        }

        adcreative_id = @facebook_ads_client.create_adcreative(name, object_story_spec)

        expect(adcreative_id.id).to eq("120330000025689603")
      end
    end 
    
    it 'creates an ad pixel' do
      VCR.use_cassette 'facebook_ads_client/create_ad_pixel' do
        account_id = "act_115443465928527"
        name = "Track this 2.0"
        
        @ad_pixel = @facebook_ads_client.create_ad_pixel(account_id, name)

        expect(@ad_pixel[:data][0]["id"]).to eq("146149006094052")
      end
    end
    
    it 'gets an ad pixel' do
      VCR.use_cassette 'facebook_ads_client/get_ad_pixel' do
        account_id = "act_115443465928527"
        name = "Track this 2.0"
        
        @ad_pixel = @facebook_ads_client.get_ad_pixel(account_id, name)

        expect(@ad_pixel[0][:id]).to eq("146149006094052")
      end
    end
    
    #The sandbox account only returns the ad id and will not appear in the ads manager
    it 'creates an ad' do
      VCR.use_cassette 'facebook_ads_client/get_ad_pixel' do
        account_id = "act_115443465928527"
        name = "Track this"
        @ad_pixel = @facebook_ads_client.get_ad_pixel(account_id, name)
      end

      VCR.use_cassette 'facebook_ads_client/create_ad' do
        object_story_spec = {
          creative: { creative_id: 120330000018226903 },
          adset_id: "120330000025683203",
          tracking_specs: "146149006094052",
          name: "Track this",
          status: 'PAUSED'
        }
        
        ad = @facebook_ads_client.create_ad(object_story_spec)
        
        expect(ad.id).to eq("120330000025695603")
      end
    end
  end
end