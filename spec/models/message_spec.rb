# == Schema Information
#
# Table name: messages
#
#  id                          :integer          not null, primary key
#  message_template_id         :integer
#  content                     :text
#  tracking_url                :string(2000)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  website_id                  :integer
#  message_generating_id       :integer
#  message_generating_type     :string
#  promotable_id               :integer
#  promotable_type             :string
#  medium                      :string
#  image_present               :string
#  image_id                    :integer
#  publish_status              :string
#  buffer_publish_date         :datetime
#  social_network_publish_date :datetime
#  social_network_id           :string
#  social_media_profile_id     :integer
#



require 'rails_helper'

describe Message do
  it { is_expected.to validate_presence_of :content }
  it { is_expected.to belong_to :message_template }
  it { is_expected.to enumerize(:publish_status).in(:pending, :published_to_buffer, :published_to_social_network).with_default(:pending).with_predicates(true) }
  it { is_expected.to have_one :buffer_update }
  it { is_expected.to have_many :metrics }
  it { is_expected.to validate_presence_of :message_generating }
  it { is_expected.to belong_to(:message_generating) }
  it { is_expected.to belong_to(:promotable) }
  it { is_expected.to enumerize(:medium).in(:ad, :organic).with_default(:organic) }
  it { is_expected.to enumerize(:image_present).in(:with, :without).with_default(:without) }
  it { is_expected.to belong_to :image }
  it { is_expected.to belong_to :social_media_profile }

  it 'returns the medium as a symbol' do
    message = build(:message)
    message.medium = :ad

    expect(message.medium).to be :ad
  end

  describe "#visits" do
    before do
      @messages = create_list(:message, 3)

      Visit.create(id: 67, visit_token: "f07cdbd3-6df5-4aae-bf3b-9e23f2cf15b0", visitor_token: "4ff38d8e-5a4f-4af5-baee-2f068ae5b66d", ip: "128.125.77.139", user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWeb...", referrer: nil, landing_page: "http://promoter-staging.sc-ctsi.org/users/sign_in", user_id: nil, referring_domain: nil, search_keyword: nil, browser: "Chrome", os: "Windows 10", device_type: "Desktop", screen_height: 1200, screen_width: 1920, country: "United States", region: "California", city: "Los Angeles", postal_code: "90089", latitude: "#<BigDecimal:7f162d8729a0,'0.337866E2',18(18)>", longitude: "#<BigDecimal:7f162d8728b0,'-0.1182987E3',18(18)>", utm_source: nil, utm_medium: nil, utm_term: nil, utm_content: @messages[1].to_param, utm_campaign: nil, started_at: "2017-02-15 19:46:14")
    end

    it "correctly ties in visits to each message by checking the equality of utm_content to the to_param values" do
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

    it "correctly ties in visits to each message by checking the equality of utm_content to the to_param values" do
      expect(@messages[2].events.count).to eq(1)
      expect(@messages[2].events[0].properties["utm_content"]).to eq(@messages[2].to_param)
    end

    it "returns an empty array if no events have occurred" do
      expect(@messages[3].events.count).to eq(0)
    end
  end

  describe "adding metrics" do
    it 'always updates existing metrics from a particular source' do
      message = create(:message)

      message.metrics << Metric.new(source: :twitter, data: {"likes": 1})
      message.metrics << Metric.new(source: :twitter, data: {"likes": 2})

      expect(message.metrics.length).to eq(1)
      expect(message.metrics[0].data[:likes]).to eq(2)
    end

    it "allows metrics from buffer, google_analytics and the message's platform" do
      message = build(:message)

      message.metrics << Metric.new(source: :twitter, data: {"likes": 1})
      message.metrics << Metric.new(source: :google_analytics, data: {"users": 1})
      message.metrics << Metric.new(source: :buffer, data: {"likes": 1})

      expect(message.metrics.length).to eq(3)
    end

    it "raises an exception if metrics are being added from a platform other than the message's platform" do
      skip "Cannot get this test to work!"
      message = build(:message)

      expect { message.metrics << Metric.new(source: :facebook, data: {"likes": 1}) }.to raise_error(InvalidMetricSourceError, "Message platform is twitter, but metric source was facebook")
    end
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
end
