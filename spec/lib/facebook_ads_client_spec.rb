require 'rails_helper'

RSpec.describe FacebookAdsClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:facebook_ads_access_token).and_return(secrets['facebook_ads_access_token'])
    allow(Setting).to receive(:[]).with(:facebook_app_secret).and_return(secrets['facebook_app_secret'])
    @facebook_ads_client = FacebookAdsClient.new("act_115443465928527")
    @ad_account = @facebook_ads_client.get_account
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
        
        campaign_params = {
          name: "Healthy Living Campaign",
          objective: "LINK_CLICKS",
          status: "ACTIVE",
          kpi_type: "LINK_CLICKS"
        }
        
        @facebook_ads_client.create_campaign(campaign_params) 
        @facebook_ads_client.get_account
        
        expect(@facebook_ads_client.get_campaign_names.count).to eq(1)
        expect(@facebook_ads_client.get_campaign_names).to include('Healthy Living Campaign')
      end
    end
    
    it 'destroys a campaign' do
      VCR.use_cassette 'facebook_ads_client/delete_campaign' do
        campaign_params = {
          name: "Keep Kalm and Keto On Kampaign",
          objective: "LINK_CLICKS",
          status: "ACTIVE",
          kpi_type: "LINK_CLICKS"
        }
        @facebook_ads_client.create_campaign(campaign_params)  
        all_campaign_ids = @facebook_ads_client.get_campaign_ids
        
        expect(@facebook_ads_client.get_campaign_names.count).to be > 0
        expect(all_campaign_ids.count).to be > 0
        
        all_campaign_ids.each do |campaign_id|
          @facebook_ads_client.delete_campaign(campaign_id)
        end

        # reload the ad_account 
        @ad_account = @facebook_ads_client.get_account
    
        expect(@facebook_ads_client.get_campaign_names.count).to eq(0)
        expect(@facebook_ads_client.get_campaign_ids.count).to eq(0)
      end
    end
    
    it 'raises an exception if a non-existent campaign' do
      VCR.use_cassette 'facebook_ads_client/delete_campaign' do
      end
    end
    
    it 'gets the campaigns' do
      VCR.use_cassette 'facebook_ads_client/get_campaign_ids' do
        @facebook_ads_client.get_campaign_ids.each{ |campaign| @facebook_ads_client.delete_campaign(campaign) }
        @ad_account = @facebook_ads_client.get_account
        
        expect(@facebook_ads_client.get_campaign_ids.count).to eq(0)
        
        campaign_params = {
          name: "Live Long and Prosper Campaign",
          objective: "LINK_CLICKS",
          status: "ACTIVE",
          kpi_type: "LINK_CLICKS"
        }
        @facebook_ads_client.create_campaign(campaign_params)
        @ad_account = @facebook_ads_client.get_account

        expect(@facebook_ads_client.get_campaign_ids.count).to eq(1)
        expect(@facebook_ads_client.get_campaign_ids[0]).to eq("120330000026550903")
      end
    end
    
    it 'gets the ad sets from a campaign' do
      VCR.use_cassette 'facebook_ads_client/get_ad_sets' do
        ad_sets =  @facebook_ads_client.get_ad_sets
  
        expect(ad_sets.count).to eq(1)
        expect(ad_sets[0].name).to eq(:adsets)
        expect(ad_sets[0].node.id).to eq("120330000026550903")
      end
    end
    
    #REF https://developers.facebook.com/docs/marketing-api/reference/ad-campaign
    it 'creates an ad set' do
      # Set up both parent child and child parent relationships between experiment and message_genreation_parameter_set
      experiment = build(:experiment)
      message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: experiment, message_run_duration_in_days: 2)
      experiment.message_generation_parameter_set = message_generation_parameter_set
      
      message = build(:message, message_generating: experiment)
      message.scheduled_date_time = Time.now

      VCR.use_cassette 'facebook_ads_client/create_ad_set' do
        ad_set_targeting = {
          geo_locations: {
            countries: ['US']
          }
        }
        ad_set_promoted_object = {
          application_id: '135216893922228'
        }
        
        ad_set_params = {
          name: "Eat More Fat",
          campaign_id: "120330000026550903",
          billing_event: "IMPRESSIONS",  
          status: "PAUSED", 
          targeting: ad_set_targeting,
          bid_amount: 3000,
          daily_budget: nil,
          lifetime_budget: 100000,
          pacing_type: ['day_parting'],
          end_time: message.end_time,
          adset_schedule: [{
            start_minute: message.setup_start_minute,
            end_minute: message.setup_end_minute,
            days: [0, 1, 2, 3, 4, 5, 6],
          }],
          promoted_object: ad_set_promoted_object,
          optimization_goal: 'IMPRESSIONS'
        }
        
        ad_set = @facebook_ads_client.create_ad_set(ad_set_params)

        expect(ad_set.id).to eq("120330000026551503")
      end
    end 
        
    #REF https://developers.facebook.com/docs/marketing-api/reference/ad-campaign
    it 'creates an ad set schedule from a message (message_generating)' do
      # Set up both parent child and child parent relationships between experiment and message_genreation_parameter_set
      experiment = build(:experiment)
      message_generation_parameter_set = build(:message_generation_parameter_set, message_generating: experiment, message_run_duration_in_days: 2)
      experiment.message_generation_parameter_set = message_generation_parameter_set
      
      campaign_id = "120330000026550903"
      message = build(:message, message_generating: experiment)
      message.scheduled_date_time = Time.now
      # start_minute = message.scheduled_date_time.strftime("%-H").to_i * 60
      # end_minute = start_minute + 60
      VCR.use_cassette 'facebook_ads_client/create_ad_set_from_message' do
        ad_set_targeting = {
          geo_locations: {
            countries: ['US']
          }
        }
        ad_set_promoted_object = {
          application_id: '135216893922228'
        }
        
        ad_set_params = {
          name: "Eat More Fat",
          campaign_id: "120330000026550903",
          billing_event: "IMPRESSIONS",  
          status: "ACTIVE", 
          targeting: ad_set_targeting,
          bid_amount: 3000,
          daily_budget: nil,
          lifetime_budget: 100000,
          pacing_type: ['day_parting'],
          end_time: message.end_time,
          adset_schedule: [{
            start_minute: message.setup_start_minute,
            end_minute: message.setup_end_minute
          }],
          promoted_object: ad_set_promoted_object,
          optimization_goal: 'IMPRESSIONS'
        }
              
        allow(@facebook_ads_client).to receive(:create_ad_set)
        allow(@facebook_ads_client).to receive(:create_ad_set_from_message).and_call_original
  
        @facebook_ads_client.create_ad_set_from_message(campaign_id, message)
        
        expect(@facebook_ads_client).to have_received(:create_ad_set).with(ad_set_params)
      end
    end 
    
    #REF https://developers.facebook.com/docs/marketing-api/reference/ad-campaign/ads/
    it 'creates an ad creative' do
      VCR.use_cassette 'facebook_ads_client/create_ad_creative' do
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

        ad_creative_id = @facebook_ads_client.create_ad_creative(name, object_story_spec)

        expect(ad_creative_id.id).to eq("120330000027414503")
      end
    end
    
    it 'allows ad creative to be created with message content and tracking url' do
      message = build(:message, tracking_url: 'http://www.test.com')

      object_story_spec = {
          page_id: "641520102717189",
          template_data: {
            additional_image_index: 0,
            call_to_action: { type: 'LEARN_MORE' },
            description: 'Live Longer',
            message: message.content,
            link: message.tracking_url,
            name: "Treat Yoself!"
          }
        }
      
      allow(@facebook_ads_client).to receive(:create_ad_creative)
      allow(@facebook_ads_client).to receive(:create_ad_creative_from_message).and_call_original

      @facebook_ads_client.create_ad_creative_from_message(message)
      
      expect(@facebook_ads_client).to have_received(:create_ad_creative).with("Stress Less!", object_story_spec)
    end
    
    it 'creates an ad creative using a message' do
      message = create(:message)
      message.tracking_url = 'www.example.com'
      
      VCR.use_cassette 'facebook_ads_client/create_ad_creative_from_message' do
        ad_creative_id = @facebook_ads_client.create_ad_creative_from_message(message)

        expect(ad_creative_id.id).to eq("120330000027548403")
      end
    end 
    
    it 'creates an ad from preset ad_creative and ad_set' do
      VCR.use_cassette 'facebook_ads_client/create_ad_from_ad_creative_and_ad_set' do
        creative_id = { creative_id: 120330000026551103 }
        ad_set_id = "120330000026551503"
        object_story_spec = {
          creative: creative_id,
          adset_id: ad_set_id,
          name: "Some Ad",
          status: 'ACTIVE'
        }
        
        allow(@facebook_ads_client).to receive(:create_ad)
        allow(@facebook_ads_client).to receive(:create_ad_from_ad_creative_and_ad_set).and_call_original
  
        @facebook_ads_client.create_ad_from_ad_creative_and_ad_set(creative_id, ad_set_id)
        
        expect(@facebook_ads_client).to have_received(:create_ad).with(object_story_spec)
      end
    end
    
    it 'creates an ad' do
      VCR.use_cassette 'facebook_ads_client/create_ad' do
        object_story_spec = {
          creative: { creative_id: 120330000026551003 },
          adset_id: "120330000026551503",
          name: "Track this",
          status: 'PAUSED'
        }
    
        ad = @facebook_ads_client.create_ad(object_story_spec)
        
        expect(ad.id).to eq("120330000026552403")
      end
    end
  end
end