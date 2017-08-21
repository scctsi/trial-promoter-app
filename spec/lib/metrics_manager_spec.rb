require 'rails_helper'

RSpec.describe MetricsManager do
  before do
    @messages = create_list(:message, 4)
    @messages[0..2].each.with_index do |message, index|
      message.social_network_id = "#{message.message_template.platform}-#{index}"
      message.save
    end
    @messages[3].campaign_id = "facebook-3"
    @messages[3].save
  end

  it 'gets the value for a metric given a message, source of the metric and the metric name' do
    data = { @messages[0].to_param => { 'metric_1' => 1, 'metric_2' => 2}, @messages[1].to_param => { 'metric_1' => 2, 'metric_2' => 3}, @messages[2].to_param => { 'metric_1' => 3, 'metric_2' => 4} }
    MetricsManager.update_metrics(data, :google_analytics)
    data = { @messages[0].social_network_id => { 'metric_1' => 4, 'metric_2' => 5}, @messages[1].social_network_id => { 'metric_1' => 4, 'metric_2' => 5}, @messages[2].social_network_id => { 'metric_1' => 5, 'metric_2' => 6} }
    MetricsManager.update_metrics(data, :twitter)

    metric_value = MetricsManager.get_metric_value(@messages[0], :google_analytics, 'metric_1')

    expect(metric_value).to eq(1)
  end

  it 'returns N/A if it cannot find a metric with the given source' do
    data = { @messages[0].to_param => { 'metric_1' => 1, 'metric_2' => 2}, @messages[1].to_param => { 'metric_1' => 2, 'metric_2' => 3}, @messages[2].to_param => { 'metric_1' => 3, 'metric_2' => 4} }
    MetricsManager.update_metrics(data, :google_analytics)
    data = { @messages[0].social_network_id => { 'metric_1' => 4, 'metric_2' => 5}, @messages[1].social_network_id => { 'metric_1' => 4, 'metric_2' => 5}, @messages[2].social_network_id => { 'metric_1' => 5, 'metric_2' => 6} }
    MetricsManager.update_metrics(data, :twitter)

    metric_value = MetricsManager.get_metric_value(@messages[0], :facebook, 'metric_1')

    expect(metric_value).to eq('N/A')
  end

  it 'returns N/A if it cannot find a metric with the given metric name' do
    data = { @messages[0].to_param => { 'metric_1' => 1, 'metric_2' => 2}, @messages[1].to_param => { 'metric_1' => 2, 'metric_2' => 3}, @messages[2].to_param => { 'metric_1' => 3, 'metric_2' => 4} }
    MetricsManager.update_metrics(data, :google_analytics)
    data = { @messages[0].social_network_id => { 'metric_1' => 4, 'metric_2' => 5}, @messages[1].social_network_id => { 'metric_1' => 4, 'metric_2' => 5}, @messages[2].social_network_id => { 'metric_1' => 5, 'metric_2' => 6} }
    MetricsManager.update_metrics(data, :twitter)

    metric_value = MetricsManager.get_metric_value(@messages[0], :twitter, 'unknown_metric')

    expect(metric_value).to eq('N/A')
  end

  it 'updates metrics for messages given a hash of metric hashes indexed by message to_param values (google_analytics source)' do
    data = { @messages[0].to_param => { 'metric_1' => 1, 'metric_2' => 2}, @messages[1].to_param => { 'metric_1' => 2, 'metric_2' => 3}, @messages[2].to_param => { 'metric_1' => 3, 'metric_2' => 4} }

    MetricsManager.update_metrics(data, :google_analytics)

    @messages.each { |message| message.reload }
    @messages[0..2].each { |message| expect(message.metrics.count).to eq(1) }
    @messages[0..2].each { |message| expect(message.metrics[0].source).to eq(:google_analytics) }
    expect(@messages[0].metrics[0].data).to eq({ 'metric_1' => 1, 'metric_2' => 2 })
    expect(@messages[1].metrics[0].data).to eq({ 'metric_1' => 2, 'metric_2' => 3 })
    expect(@messages[2].metrics[0].data).to eq({ 'metric_1' => 3, 'metric_2' => 4 })
  end

  it 'raises an exception if any message param is not found' do
    data = { 'unknown-param-0' => { 'metric_1' => 1, 'metric_2' => 2}, @messages[1].to_param => { 'metric_1' => 2, 'metric_2' => 3}, @messages[2].to_param => { 'metric_1' => 3, 'metric_2' => 4} }

    expect { MetricsManager.update_metrics(data, :google_analytics) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'updates metrics for messages given a hash of metric hashes indexed by the social network id' do
    data = { @messages[0].social_network_id => { 'metric_1' => 1, 'metric_2' => 2}, @messages[1].social_network_id => { 'metric_1' => 2, 'metric_2' => 3}, @messages[2].social_network_id => { 'metric_1' => 3, 'metric_2' => 4} }

    MetricsManager.update_metrics(data, :twitter)

    @messages.each { |message| message.reload }
    @messages[0..2].each { |message| expect(message.metrics.count).to eq(1) }
    @messages[0..2].each { |message| expect(message.metrics[0].source).to eq(:twitter) }
    expect(@messages[0].metrics[0].data).to eq({ 'metric_1' => 1, 'metric_2' => 2 })
    expect(@messages[1].metrics[0].data).to eq({ 'metric_1' => 2, 'metric_2' => 3 })
    expect(@messages[2].metrics[0].data).to eq({ 'metric_1' => 3, 'metric_2' => 4 })
  end
  
  it 'updates metrics for messages given a hash of metric hashes indexed by the campaign id' do
    data = { @messages[3].campaign_id => { 'metric_1' => 1, 'metric_2' => 2} }

    MetricsManager.update_metrics(data, :facebook)

    expect(@messages[3].metrics.count).to eq(1)
    expect(@messages[3].metrics[0].source).to eq(:facebook)
    expect(@messages[3].metrics[0].data).to eq({ 'metric_1' => 1, 'metric_2' => 2 })
  end
  
  it 'adds impressions indexed by date given a hash of impressions indexed by the social network id' do
    data = { @messages[0].social_network_id => 100, @messages[1].social_network_id => 200, @messages[2].social_network_id => 150 }

    MetricsManager.update_impressions_by_day(Date.new(2017, 4, 19), data)

    @messages.each { |message| message.reload }
    expect(@messages[0].impressions_by_day).to eq({Date.new(2017, 4, 19) => 100})
    expect(@messages[1].impressions_by_day).to eq({Date.new(2017, 4, 19) => 200})
    expect(@messages[2].impressions_by_day).to eq({Date.new(2017, 4, 19) => 150})
  end
  
  it 'adds a new impressions value given a date that does not already exist in the impressions_by_day hash' do
    data = { @messages[0].social_network_id => 100, @messages[1].social_network_id => 200, @messages[2].social_network_id => 150 }

    MetricsManager.update_impressions_by_day(Date.new(2017, 4, 19), data)
    MetricsManager.update_impressions_by_day(Date.new(2017, 4, 20), data)

    @messages.each { |message| message.reload }
    expect(@messages[0].impressions_by_day).to eq({Date.new(2017, 4, 19) => 100, Date.new(2017, 4, 20) => 100})
    expect(@messages[1].impressions_by_day).to eq({Date.new(2017, 4, 19) => 200, Date.new(2017, 4, 20) => 200})
    expect(@messages[2].impressions_by_day).to eq({Date.new(2017, 4, 19) => 150, Date.new(2017, 4, 20) => 150})
  end

  it 'replaces the impressions given a date that already exists in the impressions_by_day hash' do
    data = { @messages[0].social_network_id => 100, @messages[1].social_network_id => 200, @messages[2].social_network_id => 150 }
    data_2 = { @messages[0].social_network_id => 11, @messages[1].social_network_id => 22, @messages[2].social_network_id => 55 }

    MetricsManager.update_impressions_by_day(Date.new(2017, 4, 19), data)
    MetricsManager.update_impressions_by_day(Date.new(2017, 4, 19), data_2)

    @messages.each { |message| message.reload }
    expect(@messages[0].impressions_by_day).to eq({Date.new(2017, 4, 19) => 11})
    expect(@messages[1].impressions_by_day).to eq({Date.new(2017, 4, 19) => 22})
    expect(@messages[2].impressions_by_day).to eq({Date.new(2017, 4, 19) => 55})
  end
end