require 'rails_helper'

RSpec.describe AnalyticsDataParser do
  describe 'when data is matched via social_network_id' do
    before do
      @messages = create_list(:message, 3, platform: :twitter)
      @messages[0..1].each do |message|
        message.social_network_id = "social_network_id_#{message.id}"
        message.save
      end
      @data = OpenStruct.new
      @data.column_headers = ['social_network_id', 'impressions', 'likes', 'shares', '', '', '', 'clicks']
      @data.rows = []
      @data.rows << [@messages[0].social_network_id, '1', '2', '3', '4', '5', '6', '7']
      @data.rows << [@messages[1].social_network_id, '8', '9', '10', '11', '12', '13', '14']
    end

    it 'transforms data from Twitter analytics (organic), by parsing the out the Tweet ID from the permalink' do
      @data.rows = []
      @data.rows << [@messages[0].social_network_id, 'https://twitter.com/TCORSStgOrg/status/849049020249120769', '2', '3', '4', '5', '6', '7']
      @data.rows << [@messages[1].social_network_id, 'https://twitter.com/TCORSStgOrg/status/849018827384000512', '9', '10', '11', '12', '13', '14']

      transformed_data = AnalyticsDataParser.transform(@data, {:operation => :parse_tweet_id_from_permalink, :permalink_column_index => 1})

      expect(transformed_data.rows[0]).to eq(["849049020249120769", 'https://twitter.com/TCORSStgOrg/status/849049020249120769', '2', '3', '4', '5', '6', '7'])
      expect(transformed_data.rows[1]).to eq(["849018827384000512", 'https://twitter.com/TCORSStgOrg/status/849018827384000512', '9', '10', '11', '12', '13', '14'])
    end

    it 'parses data into a format that can be used to add metrics to individual messages' do
      parsed_data = AnalyticsDataParser.parse(@data)

      expect(parsed_data).to eq({ @messages[0].to_param => { 'impressions' => 1, 'likes' => 2, 'shares' => 3, 'clicks' => 7}, @messages[1].to_param => { 'ga:sessions' => 2, 'ga:users' => 3}, @messages[1].to_param => { 'impressions' => 8, 'likes' => 9, 'shares' => 10, 'clicks' => 14} })
    end

    it 'ignores rows where a buffer update cannot be found with that particular service update id' do
      @data.rows << ['missing_social_network_id', 'https://twitter.com/TCORSStgOrg/status/849018827384000512', '9', '10', '11', '12', '13', '14']

      parsed_data = AnalyticsDataParser.parse(@data)

      expect(parsed_data).to eq({ @messages[0].to_param => { 'impressions' => 1, 'likes' => 2, 'shares' => 3, 'clicks' => 7}, @messages[1].to_param => { 'ga:sessions' => 2, 'ga:users' => 3}, @messages[1].to_param => { 'impressions' => 8, 'likes' => 9, 'shares' => 10, 'clicks' => 14} })
    end

    it 'stores parsed data on the respective messages (matched by service_update_id)' do
      parsed_data = { @messages[0].to_param => { 'impressions' => 1, 'likes' => 2, 'shares' => 3, 'clicks' => 7}, @messages[1].to_param => { 'ga:sessions' => 2, 'ga:users' => 3}, @messages[1].to_param => { 'impressions' => 8, 'likes' => 9, 'shares' => 10, 'clicks' => 14} }

      AnalyticsDataParser.store(parsed_data, :twitter)

      @messages[0].reload
      expect(@messages[0].metrics.count).to eq(1)
      expect(@messages[0].metrics[0].data).to eq({ 'impressions' => 1, 'likes' => 2, 'shares' => 3, 'clicks' => 7})
      expect(@messages[0].metrics[0].source).to eq(:twitter)
      @messages[1].reload
      expect(@messages[1].metrics.count).to eq(1)
      expect(@messages[1].metrics[0].data).to eq({ 'impressions' => 8, 'likes' => 9, 'shares' => 10, 'clicks' => 14})
      expect(@messages[1].metrics[0].source).to eq(:twitter)
    end
  end

  describe 'when data is matched via campaign_id (Facebook and Instagram ads)' do
    before do
      @messages = create_list(:message, 3, platform: :facebook)
      @messages[0..1].each do |message|
        message.campaign_id = "campaign_id_#{message.id}"
        message.save
      end
      @data = OpenStruct.new
      @data.column_headers = ['','','campaign_id', 'impressions', 'likes', 'shares', '', '', '', 'clicks']
      @data.rows = []
      @data.rows << ['', '', @messages[0].campaign_id, '1', '2', '3', '4', '5', '6', '7']
      @data.rows << ['', '', @messages[1].campaign_id, '8', '9', '10', '11', '12', '13', '14']
    end

    it 'parses data into a format that can be used to add metrics to individual messages' do
      parsed_data = AnalyticsDataParser.parse(@data, 'campaign_id')

      expect(parsed_data).to eq({ @messages[0].to_param => { 'impressions' => 1, 'likes' => 2, 'shares' => 3, 'clicks' => 7}, @messages[1].to_param => { 'ga:sessions' => 2, 'ga:users' => 3}, @messages[1].to_param => { 'impressions' => 8, 'likes' => 9, 'shares' => 10, 'clicks' => 14} })
    end

    it 'ignores rows where a buffer update cannot be found with that particular service update id' do
      @data.rows << ['missing_social_network_id', 'https://twitter.com/TCORSStgOrg/status/849018827384000512', '9', '10', '11', '12', '13', '14']

      parsed_data = AnalyticsDataParser.parse(@data, 'campaign_id')

      expect(parsed_data).to eq({ @messages[0].to_param => { 'impressions' => 1, 'likes' => 2, 'shares' => 3, 'clicks' => 7}, @messages[1].to_param => { 'ga:sessions' => 2, 'ga:users' => 3}, @messages[1].to_param => { 'impressions' => 8, 'likes' => 9, 'shares' => 10, 'clicks' => 14} })
    end

    it 'stores parsed data on the respective messages (matched by service_update_id)' do
      parsed_data = { @messages[0].to_param => { 'impressions' => 1, 'likes' => 2, 'shares' => 3, 'clicks' => 7}, @messages[1].to_param => { 'ga:sessions' => 2, 'ga:users' => 3}, @messages[1].to_param => { 'impressions' => 8, 'likes' => 9, 'shares' => 10, 'clicks' => 14} }

      AnalyticsDataParser.store(parsed_data, :twitter)

      @messages[0].reload
      expect(@messages[0].metrics.count).to eq(1)
      expect(@messages[0].metrics[0].data).to eq({ 'impressions' => 1, 'likes' => 2, 'shares' => 3, 'clicks' => 7})
      expect(@messages[0].metrics[0].source).to eq(:twitter)
      @messages[1].reload
      expect(@messages[1].metrics.count).to eq(1)
      expect(@messages[1].metrics[0].data).to eq({ 'impressions' => 8, 'likes' => 9, 'shares' => 10, 'clicks' => 14})
      expect(@messages[1].metrics[0].source).to eq(:twitter)
    end
  end

  describe 'converting downloaded analytics files to parseable data' do
    it 'converts a CSV file exported from analytics.twitter.com (organic Twitter data) to parseable data' do
      csv_content = CSV.read("#{Rails.root}/spec/fixtures/tweet_activity_metrics_TCORSStgOrg_20170401_20170408_en.csv")

      parseable_data = AnalyticsDataParser.convert_to_parseable_data(csv_content, :twitter, :organic)

      expect(parseable_data.column_headers).to eq(['social_network_id', '', '', '', 'impressions', '', '', 'retweets', 'replies', 'likes', '', 'clicks', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''])
      expect(parseable_data.rows).to eq(csv_content[1..-1])
    end

    it 'converts an Excel (.xlsx) file exported from ads.twitter.com (ad Twitter data) to parseable data' do
      excel_content = ExcelFileReader.new.read("#{Rails.root}/spec/fixtures/2017-04-01-to-2017-04-30-6hm1atwrnaio.xlsx")

      parseable_data = AnalyticsDataParser.convert_to_parseable_data(excel_content, :twitter, :ad)

      expect(parseable_data.column_headers).to eq(['', '', '', '', '', '', 'social_network_id', '', 'impressions', '', 'likes', 'retweets', 'replies', 'clicks'])
      expect(parseable_data.rows).to eq(excel_content[1..-1])
    end

    it 'converts a CSV file exported from Facebook Insights (organic Facebook data) to parseable data' do
      quote_chars = %w(" | ~ ^ & *)
      begin
        csv_content = CSV.read("#{Rails.root}/spec/fixtures/facebook_insights.csv", headers: false, quote_char: quote_chars.shift)
      rescue CSV::MalformedCSVError
        quote_chars.empty? ? raise : retry
      end

      parseable_data = AnalyticsDataParser.convert_to_parseable_data(csv_content, :facebook, :organic)

      expect(parseable_data.column_headers).to eq(['social_network_id', '', '', '', '', '', '', '', '', '', '', 'impressions', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'comments', 'likes', 'shares', '', 'clicks'])
      # NOTE: Facebook has an extra row in the header which gives a definition of each column.
      expect(parseable_data.rows).to eq(csv_content[2..-1])
    end
  end
end