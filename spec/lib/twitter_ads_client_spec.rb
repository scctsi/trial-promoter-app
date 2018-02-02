require 'rails_helper'
require 'httparty'

RSpec.describe TwitterAdsClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:twitter).and_return(secrets['twitter'])
    @twitter_ads_client = TwitterAdsClient.new(true)
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'gets the account' do
      VCR.use_cassette 'twitter_ads_client/test_setup' do
        account = @twitter_ads_client.get_account
  p account      
        expect(account.first).to include("18ce53zp9m8")
        expect(account.first.name).to include("USC Clinical Trials")
      end
    end
  
    xit 'gets the campaigns for the ad account' do
      VCR.use_cassette 'twitter_ads_client/get_campaigns' do
        campaigns = @twitter_ads_client.get_campaigns('18ce53zp9m8')

        expect(campaigns.count).to be(0)
      end
    end

    xit 'creates a new campaign' do
      VCR.use_cassette 'twitter_ads_client/create_campaign' do
        @twitter_ads_client.create_campaign
      end
    end
  end
end