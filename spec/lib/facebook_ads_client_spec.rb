require 'rails_helper'

RSpec.describe FacebookAdsClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:facebook_access_token).and_return(secrets['facebook_access_token'])
    # allow(Setting).to receive(:[]).with(:facebook_app_secret).and_return(secrets['facebook_app_secret'])
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
  end
end