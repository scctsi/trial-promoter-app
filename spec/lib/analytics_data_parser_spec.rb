require 'rails_helper'

RSpec.describe AnalyticsDataParser do
  before do
    @messages = create_list(:message, 3)
    @analytics_data = OpenStruct.new
    @analytics_data.column_headers = ["Post ID", "Permalink", "Post Message", "Type", "Countries", "Languages", "Posted", "Audience Targeting",  "Lifetime Post Total Reach", "Lifetime Post organic reach", "Lifetime Post Paid Reach", "Lifetime Post Total Impressions", "Lifetime Post Organic Impressions", "Lifetime Post Paid Impressions", "Lifetime Engaged Users", "Lifetime Post Consumers", "Lifetime Post Consumptions", "Lifetime Negative feedback", "Lifetime Negative Feedback from Users", "Lifetime Post Impressions by people who have liked your Page", "Lifetime Post reach by people who like your Page", "Lifetime Post Paid Impressions by people who have liked your Page", "Lifetime Paid reach of a post by people who like your Page", "Lifetime People who have liked your Page and engaged with your post", "Lifetime Organic watches at 95%", "Lifetime Organic watches at 95%", "Lifetime Paid watches at 95%", "Lifetime Paid watches at 95%", "Lifetime Organic Video Views", "Lifetime Organic Video Views", "Lifetime Paid Video Views", "Lifetime Paid Video Views", "Lifetime Average time video viewed", "Lifetime Video length"]

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
end