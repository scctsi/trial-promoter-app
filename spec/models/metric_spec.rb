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
  it { is_expected.to serialize(:data).as(Hash) }
end
