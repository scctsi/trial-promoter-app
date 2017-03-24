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
  
  it 'triggers a callback when destroyed is destroyed' do
    click_meter_tracking_link = create(:click_meter_tracking_link)
    allow(click_meter_tracking_link).to receive(:delete_click_meter_tracking_link)

    click_meter_tracking_link.destroy

    expect(click_meter_tracking_link).to have_received(:delete_click_meter_tracking_link)
  end
  
  it 'asks Click Meter to delete the corresponding tracking link during the before destroy callback' do
    click_meter_tracking_link = create(:click_meter_tracking_link, :click_meter_id => '101')
    allow(ClickMeterClient).to receive(:delete_tracking_link)

    click_meter_tracking_link.delete_click_meter_tracking_link

    expect(ClickMeterClient).to have_received(:delete_tracking_link).with('101')
  end
end
