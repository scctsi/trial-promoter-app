require 'rails_helper'
require 'yaml'

RSpec.describe BitlyClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:bitly_access_token).and_return(secrets['bitly_access_token'])
    @bitly_client = BitlyClient.new
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'shortens an URL while preserving the UTM parameters for that URL' do
      message = create(:message)
      campaign_url = TrackingUrl.campaign_url(message)
      short_url = ''
      
      VCR.use_cassette 'bitly_client/shorten' do
        short_url = @bitly_client.shorten(campaign_url)
      end

      p short_url    
    end
  end
end