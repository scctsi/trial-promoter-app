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
  it { is_expected.to have_many(:clicks) }
  
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

  it 'asks Click Meter to delete the corresponding tracking link during the before destroy callback (on development environment)' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
    allow(ClickMeterClient).to receive(:delete_tracking_link)

    @click_meter_tracking_link.delete_click_meter_tracking_link

    expect(ClickMeterClient).to have_received(:delete_tracking_link).with('101')
  end

  it 'ignores asking Click Meter to delete the corresponding tracking link during the before destroy callback (on test environment)' do
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
  
  it 'throttles requests to delete Click Meter tracking links (on development environments)' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
    allow(Kernel).to receive(:sleep)
    allow(ClickMeterClient).to receive(:delete_tracking_link)
    
    @click_meter_tracking_link.delete_click_meter_tracking_link
    
    expect(Kernel).to have_received(:sleep).with(0.1)
  end

  it 'ignores throttling when deleting Click Meter tracking links on test environments' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
    allow(Kernel).to receive(:sleep)
    allow(ClickMeterClient).to receive(:delete_tracking_link)
    
    @click_meter_tracking_link.delete_click_meter_tracking_link
      
    expect(Kernel).not_to have_received(:sleep).with(0.1)
  end
 
  describe "#get_clicks_by_date" do
    before do
      @click_meter_tracking_link.clicks << create_list(:click, 3, :click_time => "23 April 2017") 
      @click_meter_tracking_link.clicks << create_list(:click, 1, :click_time => "24 April 2017") 
      @click_meter_tracking_link.clicks << create_list(:click, 2, :click_time => "25 April 2017") 
      @click_meter_tracking_link.clicks << create_list(:click, 0, :click_time => "26 April 2017") 
    end

    it 'returns clicks' do
      expect((@click_meter_tracking_link.get_clicks_by_date("25 April 2017")).first).to be_instance_of(Click)
    end

    it 'returns the clicks on a link for a given date' do
      expect((@click_meter_tracking_link.get_clicks_by_date("25 April 2017")).count).to eq(2)
      expect((@click_meter_tracking_link.get_clicks_by_date("24 April 2017")).count).to eq(1)
      expect((@click_meter_tracking_link.get_clicks_by_date("23 April 2017")).count).to eq(3)
    end 

    it 'returns 0 for a given date in which there are no clicks' do
      expect((@click_meter_tracking_link.get_clicks_by_date("26 April 2017")).count).to eq(0)
    end 
  end
end
