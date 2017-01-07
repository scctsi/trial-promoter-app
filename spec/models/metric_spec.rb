# == Schema Information
#
# Table name: metrics
#
#  id         :integer          not null, primary key
#  source     :string
#  data       :text
#  message_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Metric, type: :model do
  it { is_expected.to validate_presence_of :data }
  it { is_expected.to validate_presence_of :source }
  it { is_expected.to enumerize(:source).in(:buffer, :twitter, :facebook, :instagram, :google_analytics) }
  it { is_expected.to belong_to(:message) }
  
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
