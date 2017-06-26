require 'rails_helper'
require 'google/apis/analytics_v3'

RSpec.describe GoogleAnalyticsDataParser do
  before do
    @messages = create_list(:message, 4)
    @ga_data = Google::Apis::AnalyticsV3::GaData.new
    @ga_data.column_headers = []
    %w(ga:campaign ga:sourceMedium ga:adContent).each do |dimension|
      column_header = Google::Apis::AnalyticsV3::GaData::ColumnHeader.new
      column_header.column_type = "DIMENSION"
      column_header.data_type = "STRING"
      column_header.name = dimension
      @ga_data.column_headers << column_header
    end
    %w(ga:sessions ga:users).each do |metric|
      column_header = Google::Apis::AnalyticsV3::GaData::ColumnHeader.new
      column_header.column_type = "METRIC"
      column_header.data_type = "INTEGER"
      column_header.name = metric
      @ga_data.column_headers << column_header
    end
    # Data returned by google uses the same order as the column_headers added above
    @ga_data.rows = []
    @ga_data.rows << ['trial-promoter', 'google / organic', @messages[0].to_param, '1', '2']
    @ga_data.rows << ['trial-promoter', 'google / organic', @messages[1].to_param, '2', '3']
    @ga_data.rows << ['trial-promoter', 'google / organic', @messages[2].to_param, '4', '5']
  end

  it 'parses Google Analytics data into a format that can be used to add metrics to individual messages' do
    ga_metrics = GoogleAnalyticsDataParser.parse(@ga_data)

    expect(ga_metrics).to eq({ @messages[0].to_param => { 'ga:sessions' => 1, 'ga:users' => 2}, @messages[1].to_param => { 'ga:sessions' => 2, 'ga:users' => 3}, @messages[2].to_param => { 'ga:sessions' => 4, 'ga:users' => 5} })
  end

  it 'raises an exception if asked to parse Google Analytics data with no ga:adContent dimension metric' do
    @ga_data.column_headers.delete_if { |column_header| column_header.name == 'ga:adContent' }

    expect { GoogleAnalyticsDataParser.parse(@ga_data) }.to raise_error(MissingAdContentDimensionError, 'Google Analytics data must contain the ga:adContent dimension')
  end

  it 'stores the data as metrics' do
    ga_metrics = GoogleAnalyticsDataParser.parse(@ga_data)

    GoogleAnalyticsDataParser.store(ga_metrics)
    @messages.each{ |message| message.reload }

    expect(@messages[0].metrics[0].data).to eq(ga_metrics[@messages[0].to_param])
    expect(@messages[1].metrics[0].data).to eq(ga_metrics[@messages[1].to_param])
    expect(@messages[2].metrics[0].data).to eq(ga_metrics[@messages[2].to_param])
    expect(@messages[3].metrics[0]).to eq(nil)
  end
end