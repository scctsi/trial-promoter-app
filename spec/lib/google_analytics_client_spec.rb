require 'rails_helper'

RSpec.describe GoogleAnalyticsClient do
  before do
    @experiment = build(:experiment)
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    @experiment.set_google_api_key(secrets['google_auth_json_file'])
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'can be initialized given a profiles ID (Analytics view ID)' do
      google_analytics_client = GoogleAnalyticsClient.new(@experiment, '100')

      expect(google_analytics_client.profile_id).to eq('100')
      expect(google_analytics_client.table_id).to eq('ga:100')
      expect(google_analytics_client.scopes).to eq(['https://www.googleapis.com/auth/analytics.readonly'])
      expect(google_analytics_client.google_auth_json_file).to be_a(StringIO)
      # Check that it create an authenticated Analytics service object instance.
      expect(google_analytics_client.service).not_to be_nil
      expect(google_analytics_client.service.client_options.application_name).to eq('Trial Promoter')
      expect(google_analytics_client.service.client_options.application_version).to eq('1.0.0')
    end

    it 'defines a default set of metrics and dimensions' do
      expect(GoogleAnalyticsClient::DEFAULT_METRICS).to eq(%w(ga:users ga:sessions ga:sessionDuration ga:timeOnPage ga:avgSessionDuration ga:avgTimeOnPage ga:pageviews ga:exits))
      expect(GoogleAnalyticsClient::DEFAULT_DIMENSIONS).to eq(%w(ga:campaign ga:sourceMedium ga:adContent))
    end

    it 'calls the correct method on the service object given a start and end date (using the default metrics and dimensions)' do
      google_analytics_client = GoogleAnalyticsClient.new(@experiment, '92952002')
      allow(google_analytics_client.service).to receive(:get_ga_data)

      google_analytics_client.get_data('2016-01-01', '2016-01-02')

      expect(google_analytics_client.service).to have_received(:get_ga_data).with(google_analytics_client.table_id, '2016-01-01', '2016-01-02', GoogleAnalyticsClient::DEFAULT_METRICS.join(","), dimensions: GoogleAnalyticsClient::DEFAULT_DIMENSIONS.join(","), max_results: 100000)
    end

    it 'calls the correct method on the service object given a start date, end date, metric and dimension list' do
      google_analytics_client = GoogleAnalyticsClient.new(@experiment, '92952002')
      allow(google_analytics_client.service).to receive(:get_ga_data)

      google_analytics_client.get_data('2016-01-01', '2016-01-02', %w(ga:sessions ga:users), %w(ga:campaign,ga:sourceMedium))
      expect(google_analytics_client.service).to have_received(:get_ga_data).with(google_analytics_client.table_id, '2016-01-01', '2016-01-02', 'ga:sessions,ga:users', dimensions: 'ga:campaign,ga:sourceMedium', max_results: 100000)
    end

    it 'gets data from Google Analytics' do
      google_analytics_client = GoogleAnalyticsClient.new(@experiment, '92952002')
      ga_data = nil
      metric_list = %w(ga:sessions ga:users)
      dimension_list = %w(ga:campaign ga:sourceMedium)

      VCR.use_cassette 'google_analytics_client/get_data' do
        ga_data = google_analytics_client.get_data('2016-01-01', '2016-01-02', metric_list, dimension_list)
      end

      # Check that all the requested columns are present in the returned data.
      expect(ga_data.column_headers.count).to eq(metric_list.count + dimension_list.count)
      column_index = 0
      dimension_list.each do |dimension|
        expect(ga_data.column_headers[column_index].column_type).to eq("DIMENSION")
        expect(ga_data.column_headers[column_index].data_type).to eq("STRING")
        expect(ga_data.column_headers[column_index].name).to eq(dimension)
        column_index +=1
      end
      metric_list.each do |metric|
        expect(ga_data.column_headers[column_index].column_type).to eq("METRIC")
        expect(ga_data.column_headers[column_index].data_type).to eq("INTEGER")
        expect(ga_data.column_headers[column_index].name).to eq(metric)
        column_index +=1
      end
      # Check that we got back some data
      expect(ga_data.rows.count).not_to eq(0)
    end
  end
end