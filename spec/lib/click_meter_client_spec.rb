require 'rails_helper'
require 'yaml'

RSpec.describe ClickMeterClient do
  before do
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
<<<<<<< HEAD
    @experiment = build(:experiment)
    @experiment.set_api_key(:click_meter, secrets["click_meter_api_key"])
=======
    @experiment.set_api_key(:click_meter, secrets['click_meter_api_key'])
>>>>>>> 60c7d98c6af1a2b770b67c9f19ef75370829dc3b
    allow(ClickMeterClient).to receive(:post).and_call_original
  end

  describe "(development only tests)", :development_only_tests => true do
    it 'returns the body of the POST request for creating a tracking link via the Click Meter API' do
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
        click_meter_tracking_link = ClickMeterClient.get_tracking_link(@experiment, '9948001')
      end

      expect(click_meter_tracking_link.click_meter_id).to eq('9948001')
      expect(click_meter_tracking_link.tracking_url).to eq('http://9nl.es/name-unique-to-sc-ctsi')
      expect(click_meter_tracking_link.destination_url).to eq('http://www.sc-ctsi.org')
    end

    it 'updates an existing tracking link' do
      click_meter_tracking_link = ClickMeterTrackingLink.new
      click_meter_tracking_link.tracking_url = 'http://9nl.es/name-unique-to-sc-ctsi'
      click_meter_tracking_link.destination_url = 'http://www.sc-ctsi.org'
      allow(ClickMeterClient).to receive(:get_tracking_link).and_return(click_meter_tracking_link)
      click_meter_tracking_link = create(:click_meter_tracking_link)

      ClickMeterClient.update_tracking_link(@experiment, click_meter_tracking_link)

      click_meter_tracking_link.reload
      expect(click_meter_tracking_link.tracking_url).to eq('http://9nl.es/name-unique-to-sc-ctsi')
      expect(click_meter_tracking_link.destination_url).to eq('http://www.sc-ctsi.org')
    end

    it 'returns nil if trying to get a non-existent tracking link' do
      click_meter_tracking_link = nil

      VCR.use_cassette 'click_meter/get_non_existent_tracking_link' do
        click_meter_tracking_link = ClickMeterClient.get_tracking_link(@experiment, 'non-existent')
      end

      expect(click_meter_tracking_link).to be nil
    end

    it 'returns nil if trying to get a deleted tracking link' do
      click_meter_tracking_link = nil

      VCR.use_cassette 'click_meter/get_deleted_tracking_link' do
        click_meter_tracking_link = ClickMeterClient.get_tracking_link(@experiment, '11067935')
      end

      expect(click_meter_tracking_link).to be nil
    end

    it 'uses the Click Meter API to create a tracking link' do
      click_meter_tracking_link = nil
      VCR.use_cassette 'click_meter/get_tracking_link' do
        click_meter_tracking_link = ClickMeterClient.get_tracking_link(@experiment, '9948001')
      end
      allow(ClickMeterClient).to receive(:get_tracking_link).and_return(click_meter_tracking_link)
      tracking_link = nil

      VCR.use_cassette 'click_meter/create_tracking_link' do
        tracking_link = ClickMeterClient.create_tracking_link(@experiment, 571973, 1501, 'http://www.sc-ctsi.org', 'SC CTSI', 'name-unique-to-sc-ctsi')
      end

      expect(ClickMeterClient).to have_received(:post).with('http://apiv2.clickmeter.com:80/datapoints', :body => ClickMeterClient.post_request_body_for_create_tracking_link(571973, 1501, 'http://www.sc-ctsi.org', 'SC CTSI', 'name-unique-to-sc-ctsi').to_json, :headers => { 'Content-Type' => 'application/json; charset=UTF-8', 'X-Clickmeter-Authkey' => @experiment.settings(:click_meter).api_key })
      expect(tracking_link.click_meter_id).to eq('9948001')
      expect(tracking_link.click_meter_uri).to eq('/datapoints/9948001')
    end

    it 'raises an exception when creating a tracking link with a name that already exists on that domain' do
      VCR.use_cassette 'click_meter/create_tracking_link_with_existing_name' do
        expect { ClickMeterClient.create_tracking_link(@experiment, 571973, 1501, 'http://www.sc-ctsi.org', 'SC CTSI', 'abc') }.to raise_error(ClickMeterTrackingLinkNameExistsError, 'Click Meter already has a URL named abc on domain ID 1501')
      end
    end

    it 'deletes a Click Meter tracking link using the Click Meter API' do
      VCR.use_cassette 'click_meter/delete_tracking_link' do
        tracking_link = ClickMeterClient.create_tracking_link(@experiment, 571973, 1501, 'http://www.sc-ctsi.org', 'SC CTSI', 'name-unique-to-sc-ctsi-to-be-deleted-3')
        tracking_link_id = tracking_link.click_meter_id
        ClickMeterClient.delete_tracking_link(@experiment, tracking_link_id)
        click_meter_tracking_link = ClickMeterClient.get_tracking_link(@experiment, tracking_link_id)
        expect(click_meter_tracking_link).to be nil
      end
    end

    it 'gets an array of all groups using the Click Meter API' do
      VCR.use_cassette 'click_meter/get_groups' do
        groups = ClickMeterClient.get_groups(@experiment)
        expect(groups.count).to eq(1)
        expect(groups[0].id).to eq(571973)
        expect(groups[0].name).to eq("Default")
      end
    end

    it 'gets an array of all domains (including dedicated domains) using the Click Meter API' do
      VCR.use_cassette 'click_meter/get_domains' do
        domains = ClickMeterClient.get_domains(@experiment)
        expect(domains.count).to eq(5)
        expect(domains[0].id).to eq(836)
        expect(domains[0].name).to eq("9nl.it")
        expect(domains[1].id).to eq(2361)
        expect(domains[1].name).to eq("padlock.link")
        expect(domains[2].id).to eq(18982)
        expect(domains[2].name).to eq("go.befreeoftobacco.org")
        expect(domains[3].id).to eq(18984)
        expect(domains[3].name).to eq("go-staging.befreeoftobacco.org")
        expect(domains[4].id).to eq(1501)
        expect(domains[4].name).to eq("9nl.es")
      end
    end

    it 'creates a Click Meter tracking link for a message' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      click_meter_tracking_link = ClickMeterTrackingLink.new
      message = create(:message)
      allow(ClickMeterClient).to receive(:create_tracking_link).and_return(click_meter_tracking_link)

      ClickMeterClient.create_click_meter_tracking_link(@experiment, message, 100, 200)

      expect(ClickMeterClient).to have_received(:create_tracking_link).with(@experiment, 100, 200, TrackingUrl.campaign_url(message), message.to_param, BijectiveFunction.encode(message.id))
      expect(message.click_meter_tracking_link).not_to be_nil
      expect(message.persisted?).to be_truthy
      expect(message.click_meter_tracking_link.persisted?).to be_truthy
    end

    it 'creates a Click Meter tracking link for a message (on development environment)' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
      click_meter_tracking_link = ClickMeterTrackingLink.new
      message = create(:message)
      allow(ClickMeterClient).to receive(:create_tracking_link).and_return(click_meter_tracking_link)

      ClickMeterClient.create_click_meter_tracking_link(@experiment, message, 100, 200)

      expect(ClickMeterClient).to have_received(:create_tracking_link).with(@experiment, 100, 200, TrackingUrl.campaign_url(message), message.to_param, BijectiveFunction.encode(message.id))
      expect(message.click_meter_tracking_link).not_to be_nil
      expect(message.persisted?).to be_truthy
      expect(message.click_meter_tracking_link.persisted?).to be_truthy
      click_meter_tracking_link = ClickMeterTrackingLink.new
    end

    it 'creates a fake Click Meter tracking link for a message (on test environment)' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
      click_meter_tracking_link = ClickMeterTrackingLink.new
      message = create(:message)
      allow(ClickMeterClient).to receive(:create_tracking_link).and_return(click_meter_tracking_link)

      ClickMeterClient.create_click_meter_tracking_link(@experiment, message, 100, 200)

      expect(ClickMeterClient).not_to have_received(:create_tracking_link)
      expect(message.click_meter_tracking_link).not_to be_nil
      expect(message.click_meter_tracking_link.click_meter_id).to eq(message.id.to_s)
      expect(message.click_meter_tracking_link.click_meter_uri).to eq("/datapoints/#{message.id.to_s}")
      expect(message.click_meter_tracking_link.tracking_url).to eq("http://development.tracking-domain.com/#{BijectiveFunction.encode(message.id)}")
      expect(message.click_meter_tracking_link.destination_url).to eq(TrackingUrl.campaign_url(message))
      expect(message.persisted?).to be_truthy
      expect(message.click_meter_tracking_link.persisted?).to be_truthy
    end

    it 'gets all clicks given a tracking link' do
      click_meter_tracking_link = create(:click_meter_tracking_link, click_meter_id: '12691042')
      VCR.use_cassette 'click_meter/get_clicks' do

        clicks = ClickMeterClient.get_clicks(@experiment, click_meter_tracking_link)

        expect(clicks.count).to eq(15)
        expect(clicks[0].click_meter_event_id).to eq('012691042@20170426212421792704001')
        expect(clicks[0].click_time).to eq(DateTime.strptime('20170426212421 Pacific Time (US & Canada)', '%Y%m%d%H%M%S %Z'))
        expect(clicks[0].spider).to be true
        expect(clicks[0].ip_address).to eq('66.220.145.244')
        expect(clicks[0].unique).to be true
      end
    end

    it 'gets no clicks given a blacklisted ip address' do
      exclude_ip_address_list = ["54.82.29.147", "173.252.88.87", "66.220.145.245", "66.220.145.244", "185.20.6.14", "52.202.49.192", "192.241.206.112"]
      click_meter_tracking_link = create(:click_meter_tracking_link, click_meter_id: '12691042')
      VCR.use_cassette 'click_meter/get_no_clicks_blacklisted_ip' do
        clicks = ClickMeterClient.get_clicks(@experiment, click_meter_tracking_link, exclude_ip_address_list)
        expect(clicks.count).to eq(1)
      end
    end

    it 'only saves clicks once' do
      click_meter_tracking_link = create(:click_meter_tracking_link, click_meter_id: '12691042')
      VCR.use_cassette 'click_meter/get_clicks_once' do

        ClickMeterClient.get_clicks(@experiment, click_meter_tracking_link)
        ClickMeterClient.get_clicks(@experiment, click_meter_tracking_link)

        click_meter_tracking_link.reload
        expect(click_meter_tracking_link.clicks.count).to eq(15)
      end
    end
  end
end