require 'rails_helper'

RSpec.describe GoogleAnalyticsClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:google_auth_json_file).and_return(secrets['google_auth_json_file'])
    @google_analytics_client = GoogleAnalyticsClient.new('92952002')
  end
  
  describe "(development only tests)", :development_only_tests => true do
    it 'can be initialized given a profiles ID (Analytics view ID)' do
      google_analytics_client = GoogleAnalyticsClient.new('100')
      
      expect(google_analytics_client.profile_id).to eq('100')
      expect(google_analytics_client.table_id).to eq('ga:100') 
      expect(google_analytics_client.scopes).to eq(['https://www.googleapis.com/auth/analytics.readonly'])
      expect(google_analytics_client.google_auth_json_file).to be_a(StringIO)
    end
    
    it 'creates an authenticated Analytics service instance' do
      expect(@google_analytics_client.service).not_to be_nil
      expect(@google_analytics_client.service.client_options.application_name).to eq('Trial Promoter')
      expect(@google_analytics_client.service.client_options.application_version).to eq('1.0.0')
    end
  end
end