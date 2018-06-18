require 'rails_helper'
require 'yaml'

RSpec.describe BitlyClient do
  before do
    experiment = build(:experiment)
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    experiment.set_api_key('bitly', secrets["bitly_access_token"])
    @bitly_client = BitlyClient.new(experiment)
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'shortens a URL' do
      short_url = ''
      
      VCR.use_cassette 'bitly_client/shorten' do
        short_url = @bitly_client.shorten('http://www.sc-ctsi.org/')
      end

      expect(short_url).to match(/http:\/\/bit.ly\/[A-Za-z0-9]{7}/)
    end
    
    it 'expands a URL' do
      long_url = ''
      
      VCR.use_cassette 'bitly_client/expand' do
        long_url = @bitly_client.expand('http://bit.ly/1zDgg9K')
      end
      
      expect(long_url).to eq('http://www.sc-ctsi.org/')
    end

    it 'retains URM parameters present in a URL' do
      campaign_url = 'http://www.website.com/?utm_source=twitter&utm_campaign=957-name&utm_medium=organic&utm_term=&utm_content=957-name-message-2838'
      short_url = ''
      long_url = ''
      
      VCR.use_cassette 'bitly_client/shorten_url_with_utm_parameters' do
        short_url = @bitly_client.shorten(campaign_url)
      end

      expect(short_url).to match(/http:\/\/bit.ly\/[A-Za-z0-9]{7}/)
      VCR.use_cassette 'bitly_client/expand_url_with_utm_parameters' do
        long_url = @bitly_client.expand(short_url)
      end
      expect(long_url).to eq(campaign_url)
    end
  end
end