require 'rails_helper'

RSpec.describe GoogleAnalyticsClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:google_auth_json_file).and_return(secrets['google_auth_json_file'])
  end
  
  describe "(development only tests)", :development_only_tests => true do
    it 'can be initialized given a profiles ID (Analytics view ID)' do
      google_analytics_client = GoogleAnalyticsClient.new('100')

      expect(google_analytics_client.profile_id).to eq('100')
      expect(google_analytics_client.table_id).to eq('ga:100') 
      expect(google_analytics_client.scopes).to eq(['https://www.googleapis.com/auth/analytics.readonly'])
      expect(google_analytics_client.google_auth_json_file).to be_a(StringIO)
      # Also check that it creates an authenticated Analytics service object instance'
      expect(google_analytics_client.service).not_to be_nil
      expect(google_analytics_client.service.client_options.application_name).to eq('Trial Promoter')
      expect(google_analytics_client.service.client_options.application_version).to eq('1.0.0')
    end
    
    it 'defines a default set of metrics and dimensions' do
      expect(GoogleAnalyticsClient::DEFAULT_METRICS).to eq('ga:users,ga:sessions,ga:sessionDuration,ga:timeOnPage,ga:avgSessionDuration,ga:avgTimeOnPage,ga:pageviews,ga:exits')
      expect(GoogleAnalyticsClient::DEFAULT_DIMENSIONS).to eq('ga:campaign,ga:sourceMedium,ga:adContent')
    end
    
    it 'gets analytics data given a start and end date (using the default metrics and dimensions)' do
      google_analytics_client = GoogleAnalyticsClient.new('92952002')
      allow(google_analytics_client.service).to receive(:get_ga_data)

      google_analytics_client.get_data('2016-01-01', '2016-01-02')
      
      expect(google_analytics_client.service).to have_received(:get_ga_data).with(google_analytics_client.table_id, '2016-01-01', '2016-01-02', GoogleAnalyticsClient::DEFAULT_METRICS, dimensions: GoogleAnalyticsClient::DEFAULT_DIMENSIONS, max_results: 100000)
    end

    it 'gets analytics data given a start, end date, metric and dimension list' do
      google_analytics_client = GoogleAnalyticsClient.new('92952002')
      allow(google_analytics_client.service).to receive(:get_ga_data)

      google_analytics_client.get_data('2016-01-01', '2016-01-02', 'gaSessions,gaUsers', 'gaCampaign,gaSourceMedium')
      
      expect(google_analytics_client.service).to have_received(:get_ga_data).with(google_analytics_client.table_id, '2016-01-01', '2016-01-02', 'gaSessions,gaUsers', dimensions: 'gaCampaign,gaSourceMedium', max_results: 100000)
    end
  end
end