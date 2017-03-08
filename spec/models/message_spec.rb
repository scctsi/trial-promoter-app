# == Schema Information
#
# Table name: messages
#
#  id                      :integer          not null, primary key
#  message_template_id     :integer
#  content                 :text
#  tracking_url            :string(2000)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  website_id              :integer
#  message_generating_id   :integer
#  message_generating_type :string
#  promotable_id           :integer
#  promotable_type         :string
#  medium                  :string
#  image_present           :string
#  image_id                :integer
#  publish_status          :string
#  buffer_publish_date     :datetime
#  scheduled_date_time     :datetime
#  social_network_id       :string
#  social_media_profile_id :integer
#  platform                :string
#

require 'rails_helper'

describe Message do
  it { is_expected.to validate_presence_of :content }
  it { is_expected.to belong_to :message_template }
  it { is_expected.to enumerize(:publish_status).in(:pending, :published_to_buffer, :published_to_social_network).with_default(:pending).with_predicates(true) }
  it { is_expected.to have_one :buffer_update }
  it { is_expected.to have_one :click_meter_tracking_link }
  it { is_expected.to have_many :metrics }
  it { is_expected.to validate_presence_of :message_generating }
  it { is_expected.to validate_presence_of :platform }
  it { is_expected.to belong_to(:message_generating) }
  it { is_expected.to belong_to(:promotable) }
  it { is_expected.to enumerize(:platform).in(:twitter, :facebook, :instagram) }
  it { is_expected.to enumerize(:medium).in(:ad, :organic).with_default(:organic) }
  it { is_expected.to enumerize(:image_present).in(:with, :without).with_default(:without) }
  it { is_expected.to belong_to :image }
  it { is_expected.to belong_to :social_media_profile }

  it 'returns the medium as a symbol' do
    message = build(:message)
    message.medium = :ad

    expect(message.medium).to be :ad
  end
  
  it 'returns the platform as a symbol' do
    message = build(:message, platform: 'twitter')

    expect(message.platform).to be(:twitter)
  end

  describe "#visits" do
    before do
      @messages = create_list(:message, 3)

      Visit.create(id: 67, visit_token: "f07cdbd3-6df5-4aae-bf3b-9e23f2cf15b0", visitor_token: "4ff38d8e-5a4f-4af5-baee-2f068ae5b66d", ip: "128.125.77.139", user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...", referrer: nil, landing_page: "http://promoter-staging.sc-ctsi.org/users/sign_in", user_id: nil, referring_domain: nil, search_keyword: nil, browser: "Chrome", os: "Windows 10", device_type: "Desktop", screen_height: 1200, screen_width: 1920, country: "United States", region: "California", city: "Los Angeles", postal_code: "90089", latitude: "#<BigDecimal:7f162d8729a0,'0.337866E2',18(18)>", longitude: "#<BigDecimal:7f162d8728b0,'-0.1182987E3',18(18)>", utm_source: nil, utm_medium: nil, utm_term: nil, utm_content: @messages[1].to_param, utm_campaign: nil, started_at: "2017-02-15 19:46:14")
    end

    it "correctly ties in visits to each message via the utm_content on the visit" do
      expect(@messages[1].visits.count).to eq(1)
      expect(@messages[1].visits[0].utm_content).to eq(@messages[1].to_param)
    end

    it "returns an empty array if no visits have occurred" do
      expect(@messages[2].visits.count).to eq(0)
    end
  end

  describe "#events" do
    before do
      @messages = create_list(:message, 4)

      Ahoy::Event.create(id: 7, visit_id: 10, user_id: nil, name: "Converted", properties: { "utm_source": "twitter", "utm_campaign": "smoking cessation", "utm_medium": "ad", "utm_term": "cessation123", "utm_content": @messages[2].to_param, "conversionTracked": true, "time": 1487207159071}, time: "2017-02-16 01:05:59")
    end

    it "correctly ties in events to each message via the utm_content on the properties for each event" do
      expect(@messages[2].events.count).to eq(1)
      expect(@messages[2].events[0].properties["utm_content"]).to eq(@messages[2].to_param)
    end

    it "returns an empty array if no events have occurred" do
      expect(@messages[3].events.count).to eq(0)
    end
  end
  
  it 'always updates existing metrics from a particular source' do
    message = build(:message)

    message.metrics << Metric.new(source: :twitter, data: {"likes": 1})
    message.metrics << Metric.new(source: :twitter, data: {"likes": 2})

    expect(message.metrics.length).to eq(1)
    expect(message.metrics[0].data[:likes]).to eq(2)
  end

  it "parameterizes id and the experiments's param together" do
    experiment = create(:experiment, name: 'TCORS 2')
    message = create(:message, message_generating: experiment)
    expect(message.to_param).to eq("#{experiment.to_param}-message-#{message.id.to_s}")
  end

  it 'finds a message by the param' do
    create(:message)

    message = Message.find_by_param(Message.first.to_param)

    expect(message).to eq(Message.first)
  end

  it 'raises an exception if a message cannot be found with a certain param' do
    expect { Message.find_by_param('unknown-param') }.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe 'pagination' do
    before do
      create_list(:message, 30)
      @messages = Message.order('created_at ASC')
    end

    it 'has a default of 25 messages per page' do
      page_of_messages = Message.page(1)

      expect(page_of_messages.count).to eq(25)
    end

    it 'returns the first page of messages given a per page value' do
      page_of_messages = Message.order('created_at ASC').page(1).per(5)

      expect(page_of_messages.count).to eq(5)
      expect(page_of_messages[0]).to eq(@messages[0])
    end

    it 'returns the second page of messages given a per page value' do
      page_of_messages = Message.order('created_at ASC').page(2).per(5)

      expect(page_of_messages.count).to eq(5)
      expect(page_of_messages[0]).to eq(@messages[5])
    end

    it 'returns a page of messages given a condition' do
      page_of_messages = Message.where(content: 'Content').order('created_at ASC').page(2).per(5)

      expect(page_of_messages.count).to eq(5)
      expect(page_of_messages[0]).to eq(@messages[5])
    end
  end

  describe "#delayed?" do
    before do
      @message = create(:message)
      @message.scheduled_date_time = "2017-10-10 13:04:00"
      @message.buffer_update = BufferUpdate.new(id: 2, buffer_id: "23423244", service_update_id: "2343225435247", status: "pending", message_id: 1128, created_at: "2017-02-17 19:55:02", updated_at: "2017-02-21 23:19:04", sent_from_date_time: "2017-10-10 13:09:22")
    end

    it 'checks if message sent from Buffer has been delayed' do
      expect(@message.delayed?).to be(true)
    end

    it 'checks if message sent from Buffer was on-time' do
      @message.scheduled_date_time = "2017-10-10 13:09:00"

      expect(@message.delayed?).to be(false)
    end
  end
end
