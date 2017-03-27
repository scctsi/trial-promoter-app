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
  
  before do
    @click_meter_tracking_link = create(:click_meter_tracking_link, :click_meter_id => '101')
  end
  
  it 'triggers a callback when destroyed' do
    allow(@click_meter_tracking_link).to receive(:delete_click_meter_tracking_link)

    @click_meter_tracking_link.destroy

    expect(@click_meter_tracking_link).to have_received(:delete_click_meter_tracking_link)
  end
  
  it 'asks Click Meter to delete the corresponding tracking link during the before destroy callback' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
    allow(ClickMeterClient).to receive(:delete_tracking_link)

    @click_meter_tracking_link.delete_click_meter_tracking_link

    expect(ClickMeterClient).to have_received(:delete_tracking_link).with('101')
  end

  it 'ignores asking Click Meter to delete the corresponding tracking link during the before destroy callback on development environment' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
    allow(ClickMeterClient).to receive(:delete_tracking_link)

    @click_meter_tracking_link.delete_click_meter_tracking_link

    expect(ClickMeterClient).not_to have_received(:delete_tracking_link).with('101')
  end

  it 'ignores asking Click Meter to delete the corresponding tracking link during the before destroy callback on test environment' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
    allow(ClickMeterClient).to receive(:delete_tracking_link)

    @click_meter_tracking_link.delete_click_meter_tracking_link

    expect(ClickMeterClient).not_to have_received(:delete_tracking_link).with('101')
  end
  
  it 'throttles requests to delete Click Meter tracking links' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
    allow(Kernel).to receive(:sleep)
    allow(ClickMeterClient).to receive(:delete_tracking_link)
    
    @click_meter_tracking_link.delete_click_meter_tracking_link
    
    expect(Kernel).to have_received(:sleep).with(0.1)
  end
  
  it 'ignores throttling when deleting Click Meter tracking links on development environments' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
    allow(Kernel).to receive(:sleep)
    allow(ClickMeterClient).to receive(:delete_tracking_link)
    
    @click_meter_tracking_link.delete_click_meter_tracking_link
    
    expect(Kernel).not_to have_received(:sleep).with(0.1)
  end

  it 'ignores throttling when deleting Click Meter tracking links on test environments' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
    allow(Kernel).to receive(:sleep)
    allow(ClickMeterClient).to receive(:delete_tracking_link)
    
    @click_meter_tracking_link.delete_click_meter_tracking_link
    
    expect(Kernel).not_to have_received(:sleep).with(0.1)
  end
end
