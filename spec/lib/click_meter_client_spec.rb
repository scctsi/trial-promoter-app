require 'rails_helper'
require 'yaml'

RSpec.describe ClickMeterClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    allow(Setting).to receive(:[]).with(:click_meter_api_key).and_return(secrets['click_meter_api_key'])
    allow(ClickMeterClient).to receive(:post).and_call_original
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'returns the body of the POST request for creating a tracking link via the ClickMeter API' do
      post_request_body = ClickMeterClient.post_request_body_for_create_tracking_link(571973, 1501, 'http://www.sc-ctsi.org', '1-tcors-message-1', BijectiveFunction.encode(1))

      expect(post_request_body["type"]).to eq(0)
      expect(post_request_body["title"]).to eq('1-tcors-message-1')
      expect(post_request_body["groupId"]).to eq(571973)
      expect(post_request_body["name"]).to eq(BijectiveFunction.encode(1))
      expect(post_request_body["typeTL"]).to eq( { "domainId" => 1501, "redirectType" => 301, "url" => 'http://www.sc-ctsi.org' })
    end

    it 'uses the Click Meter API to get information about a tracking link (datapoint)' do
      click_meter_tracking_link = nil
      
      VCR.use_cassette 'click_meter/get_tracking_link' do
        click_meter_tracking_link = ClickMeterClient.get_tracking_link('9948001')
      end

      expect(click_meter_tracking_link.click_meter_id).to eq('9948001')
      expect(click_meter_tracking_link.tracking_url).to eq('http://9nl.es/name-unique-to-sc-ctsi')
      expect(click_meter_tracking_link.destination_url).to eq('http://www.sc-ctsi.org')
    end

    it 'uses the Click Meter API To create a tracking link' do
      click_meter_tracking_link = nil
      VCR.use_cassette 'click_meter/get_tracking_link' do
        click_meter_tracking_link = ClickMeterClient.get_tracking_link('9948001')
      end
      allow(ClickMeterClient).to receive(:get_tracking_link).and_return(click_meter_tracking_link)
      tracking_link = nil

      VCR.use_cassette 'click_meter/create_tracking_link' do
        tracking_link = ClickMeterClient.create_tracking_link(571973, 1501, 'http://www.sc-ctsi.org', 'SC CTSI', 'name-unique-to-sc-ctsi')
      end

      expect(ClickMeterClient).to have_received(:post).with('http://apiv2.clickmeter.com:80/datapoints', :body => ClickMeterClient.post_request_body_for_create_tracking_link(571973, 1501, 'http://www.sc-ctsi.org', 'SC CTSI', 'name-unique-to-sc-ctsi').to_json, :headers => { 'Content-Type' => 'application/json; charset=UTF-8', 'X-Clickmeter-Authkey' => Setting[:click_meter_api_key] })
      expect(tracking_link.click_meter_id).to eq('9948001')
      expect(tracking_link.click_meter_uri).to eq('/datapoints/9948001')
      expect(tracking_link.tracking_url).to eq('http://9nl.es/name-unique-to-sc-ctsi')
      expect(tracking_link.destination_url).to eq('http://www.sc-ctsi.org')
    end
  
    it 'raises an exception when creating a tracking link with a name that already exists on that domain' do
      VCR.use_cassette 'click_meter/create_tracking_link_with_existing_name' do
        expect { ClickMeterClient.create_tracking_link(571973, 1501, 'http://www.sc-ctsi.org', 'SC CTSI', 'abc') }.to raise_error(ClickMeterTrackingLinkNameExistsError, 'Click Meter already has a URL named abc on domain ID 1501')
      end
    end
    
    it 'creates a Click Meter tracking link for a message' do
      click_meter_tracking_link = ClickMeterTrackingLink.new
      message = create(:message)
      allow(ClickMeterClient).to receive(:create_tracking_link).and_return(click_meter_tracking_link)
      
      ClickMeterClient.create_click_meter_tracking_link(message, 100, 200)
      
      expect(ClickMeterClient).to have_received(:create_tracking_link).with(100, 200, TrackingUrl.campaign_url(message), message.to_param, BijectiveFunction.encode(message.id))
      expect(message.click_meter_tracking_link).not_to be_nil
      expect(message.persisted?).to be_truthy
      expect(message.click_meter_tracking_link.persisted?).to be_truthy
    end
  end
end