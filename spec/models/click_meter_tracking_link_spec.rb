# == Schema Information
#
# Table name: click_meter_tracking_links
#
#  id              :integer          not null, primary key
#  click_meter_id  :string
#  click_meter_uri :string(2000)
#  tracking_url    :string(2000)
#  destination_url :string(2000)
#  message_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe ClickMeterTrackingLink, type: :model do
  it { is_expected.to belong_to(:message) }
  it { is_expected.to validate_presence_of(:message) }
end
