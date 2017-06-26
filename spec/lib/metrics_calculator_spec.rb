require 'rails_helper'

RSpec.describe MetricsCalculator do
  before do
    sources = [:buffer, :twitter, :facebook, :instagram, :google_analytics]
    @messages = create_list(:message, 5)
    @messages.each.with_index do |message, index|
      metric = Metric.new(data: { message.to_param => { 'metric_1' => 1, 'metric_2' => 2}}, source: sources[index])
      message.metrics << metric
    end
  end

  it 'calculates the click rate for a given set of metrics' do
    clicks = @messages[0].metrics[0].data[@messages[0].to_param]['metric_1']
    impressions = @messages[0].metrics[0].data[@messages[0].to_param]['metric_2']

    expect(MetricsCalculator.click_rate(clicks, impressions)).to eq(0.5)
  end

  it 'calculates the goal rate for a given set of metrics' do
    conversions = @messages[0].metrics[0].data[@messages[0].to_param]['metric_1']
    sessions = @messages[0].metrics[0].data[@messages[0].to_param]['metric_2']

    expect(MetricsCalculator.goal_rate(conversions, sessions)).to eq(0.5)
  end
end