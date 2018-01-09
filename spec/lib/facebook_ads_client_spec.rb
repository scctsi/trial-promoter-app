require 'rails_helper'

RSpec.describe FacebookAdsClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:facebook_access_token).and_return(secrets['facebook_access_token'])
    allow(Setting).to receive(:[]).with(:facebook_app_secret).and_return(secrets['facebook_app_secret'])
    @facebook_ads_client = FacebookAdsClient.new
    VCR.use_cassette 'facebook_ads_client/test_setup' do
      @ad_account = @facebook_ads_client.get_account('act_114516875546999')
      @ad_name = @ad_account.name
    end
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'gets the account of Tommy Trogan' do
      expect(@ad_account).not_to be_nil
      expect(@ad_account["id"]).to eq("act_114516875546999")
      expect(@ad_name).to eq("Tommy Trogan")
    end
    
    it 'gets the campaign names associated with an ad account' do
      VCR.use_cassette 'facebook_ads_client/get_campaign_names' do
        campaign_names = @facebook_ads_client.get_campaign_names
        
        expect(campaign_names.count).to eq(732)
        expect(campaign_names.first).to eq("Post: \"Hydrogen cyanide is found in rat poison. It’s...\"")
        # p campaign_names
        # expect(campaign_names.first).to include("6076509762239")
      end
    end
    
    it 'gets all the campaigns' do
      VCR.use_cassette 'facebook_ads_client/get_all_campaigns' do
        all_campaigns = @facebook_ads_client.get_all_campaigns

        expect(all_campaigns.count).to eq(732)
      end
    end
        
    it 'gets the campaign ids' do
      VCR.use_cassette 'facebook_ads_client/get_all_campaign_ids' do
        all_campaign_ids = @facebook_ads_client.get_all_campaign_ids

        expect(all_campaign_ids.count).to eq(732)
      end
    end
    
    #Each campaign has a corresponding ad set - for TCORS, it's a one-to-one relationship, 
    # see Ad Sets section: https://github.com/tophatter/facebook-ruby-ads-sdk
    it 'gets the ad sets from a campaign id' do
      VCR.use_cassette 'facebook_ads_client/get_ad_sets' do
      ads =  @facebook_ads_client.get_ad_sets

      expect(ads.count).to eq(732)
      expect(ads[0].name).to eq(:adsets)
      #This is actually the campaign id
      expect(ads[0].node.id).to eq("6076520279839")
      end
    end
    
    it 'gets the ads from the ad sets' do
      VCR.use_cassette 'facebook_ads_client/get_ads' do

        ads = @facebook_ads_client.get_ads

        expect(ads.count).to eq(731)
      end
    end 
    
    xit 'gets the comments from an ad id' do
      VCR.use_cassette 'facebook_ads_client/get_comments' do
        ad_id = "6075124407239"
        
        comments = @facebook_ads_client.get_comments(ad_id)
        
        expect(comments).to eq("something")
      end
    end
  end
end