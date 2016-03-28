require 'rails_helper'

RSpec.describe Statistic, type: :model do
  it { should validate_presence_of(:data) }
  it { should validate_presence_of(:source) }
  it { should enumerize(:source).in(:buffer, :twitter, :facebook).with_predicates(true) }
  it { should belong_to(:message) }
  
  it "should be able to store data as a hash" do
    data = {
      "reach": 2460,
      "clicks": 56,
      "retweets": 20,
      "favorites": 1,
      "mentions": 1
    }
    statistic = Statistic.new(source: :twitter, data: data)

    statistic.save
    statistic.reload
    
    expect(statistic.data).to eq(data)
  end
end
