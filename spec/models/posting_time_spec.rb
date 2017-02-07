# == Schema Information
#
# Table name: posting_times
#
#  id            :integer          not null, primary key
#  experiment_id :integer
#  posting_times :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe PostingTime, type: :model do
  it { is_expected.to validate_presence_of :experiment }
  it { is_expected.to belong_to(:experiment) }

  it 'validates posting_time as datetime' do
    posting_time = create(:posting_time)
    p posting_time['posting_times']
    expect(posting_time.posting_times).to be_an_instance_of(Array)
  end

  # it 'validates posting_time as an array of strings' do
  # end

  # it 'matches the number of posting_times with the number of messages_per_social_network_per_day'
  #end
end
