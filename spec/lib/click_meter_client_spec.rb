require 'rails_helper'
require 'yaml'

RSpec.describe ClickMeterClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:click_meter_api_key).and_return(secrets['click_meter_api_key'])
    allow(ClickMeterClient).to receive(:post).and_call_original
    @experiment = create(:experiment)
    @message = create(:message, message_generating: @experiment)
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'returns the body of the POST request for creating a tracking link via the ClickMeter API' do
      post_request_body = ClickMeterClient.post_request_body_for_create_tracking_link(@experiment, @message)

      expect(post_request_body[:type]).to eq('0')
      expect(post_request_body[:title]).to eq(@message.to_param)
      expect(post_request_body[:groupId]).to eq('572279')
      expect(post_request_body[:name]).to eq(@message.to_param)
      expect(post_request_body[:typeTL]).to eq( { domainId: '1501', redirectType: '301', url: TrackingUrl.campaign_url(@message) })
    end
    
    it 'uses the Click Meter API To create a tracking link' do
      url = ''
  
      VCR.use_cassette 'click_meter/create_tracking_link' do
        url = ClickMeterClient.create_tracking_link(@experiment, @message)
      end
      
      puts url

      expect(ClickMeterClient).to have_received(:post).with('http://apiv2.clickmeter.com/datapoints', :body => ClickMeterClient.post_request_body_for_create_tracking_link(@experiment, @message), :headers => { 'Content-Type' => 'application/json; charset=UTF-8', 'X-Clickmeter-Authkey' => Setting[:click_meter_api_key] })
    end
  end
end