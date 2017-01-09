require 'rails_helper'

RSpec.describe MetricManager do
  before do
    @messages = create_list(:message, 3)
    @messages.each.with_index do |message, index|
      message.social_network_id = "#{message.message_template.platform}-#{index}"
      message.save
    end
  end

  it 'updates metrics for messages given a hash of metric hashes indexed by message to_param values (google_analytics source)' do
    data = { @messages[0].to_param => { 'metric_1' => 1, 'metric_2' => 2}, @messages[1].to_param => { 'metric_1' => 2, 'metric_2' => 3}, @messages[2].to_param => { 'metric_1' => 3, 'metric_2' => 4} }
    
    MetricManager.update_metrics(data, :google_analytics)
    
    @messages.each { |message| expect(message.metrics.count).to eq(1) }
    @messages.each { |message| expect(message.metrics[0].source).to eq(:google_analytics) }
    expect(@messages[0].metrics[0].data).to eq({ 'metric_1' => 1, 'metric_2' => 2 })
    expect(@messages[1].metrics[0].data).to eq({ 'metric_1' => 2, 'metric_2' => 3 })
    expect(@messages[2].metrics[0].data).to eq({ 'metric_1' => 3, 'metric_2' => 4 })
  end
  
  it 'raises an exception if any message param is not found' do
    data = { 'unknown-param' => { 'metric_1' => 1, 'metric_2' => 2}, @messages[1].to_param => { 'metric_1' => 2, 'metric_2' => 3}, @messages[2].to_param => { 'metric_1' => 3, 'metric_2' => 4} }
    
    expect { MetricManager.update_metrics(data, :google_analytics) }.to raise_error(ActiveRecord::RecordNotFound)
  end
  
  it 'updates metrics for messages given a hash of metric hashes indexed by the social network id' do
    data = { @messages[0].social_network_id => { 'metric_1' => 1, 'metric_2' => 2}, @messages[1].social_network_id => { 'metric_1' => 2, 'metric_2' => 3}, @messages[2].social_network_id => { 'metric_1' => 3, 'metric_2' => 4} }
    
    MetricManager.update_metrics(data, :twitter)
    
    @messages.each { |message| expect(message.metrics.count).to eq(1) }
    @messages.each { |message| expect(message.metrics[0].source).to eq(:twitter) }
    expect(@messages[0].metrics[0].data).to eq({ 'metric_1' => 1, 'metric_2' => 2 })
    expect(@messages[1].metrics[0].data).to eq({ 'metric_1' => 2, 'metric_2' => 3 })
    expect(@messages[2].metrics[0].data).to eq({ 'metric_1' => 3, 'metric_2' => 4 })
  end

end