require 'rails_helper'

RSpec.describe AnalyticsDataParser do
  before do
    @messages = create_list(:message, 3)
    @messages[0..1].each do |message|
      message.buffer_update = build(:buffer_update, :service_update_id => "service_update_id_#{message.id}")
      message.buffer_update.save
    end
    @data = OpenStruct.new
    @data.column_headers = ['service_update_id', 'impressions', 'likes', 'shares', '', '', '', 'clicks']
    @data.rows = []
    @data.rows << [@messages[0].buffer_update.service_update_id, '1', '2', '3', '4', '5', '6', '7']
    @data.rows << [@messages[1].buffer_update.service_update_id, '8', '9', '10', '11', '12', '13', '14']
  end
  
  xit 'parses data into a format that can be used to add metrics to individual messages' do
    metrics = AnalyticsDataParser.parse(@data)

    expect(metrics).to eq({ @messages[0].to_param => { 'impressions' => 1, 'likes' => 2, 'shares' => 3, 'clicks' => 7}, @messages[1].to_param => { 'ga:sessions' => 2, 'ga:users' => 3}, @messages[1].to_param => { 'impressions' => 8, 'likes' => 9, 'shares' => 10, 'clicks' => 14} })
  end
end
