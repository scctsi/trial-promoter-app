require 'rails_helper'

RSpec.describe Metric, type: :model do
  it { should validate_presence_of :data }
  it { should validate_presence_of :source }
  it { should enumerize(:source).in(:buffer, :twitter, :facebook) }
  it { should belong_to(:message) }
  
  it 'stores data as a hash' do
    data = {
      "reach": 2460,
      "clicks": 56,
      "retweets": 20,
      "favorites": 1,
      "mentions": 1
    }
    metric = Metric.new(source: :twitter, data: data)

    metric.save
    metric.reload
    
    expect(metric.data).to eq(data)
  end
end