# == Schema Information
#
# Table name: messages
#
#  id                          :integer          not null, primary key
#  message_template_id         :integer
#  content                     :text
#  tracking_url                :string(2000)
#  buffer_profile_ids          :text
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

  it 'stores an array of Buffer profiles ids' do
    message = build(:message)
    message.buffer_profile_ids = ["1234abcd", "1234efgh", "1234ijkl"]

    message.save
    message.reload

    expect(message.buffer_profile_ids).to eq(["1234abcd", "1234efgh", "1234ijkl"])
  end
  
  describe "adding metrics" do
    it 'always updates existing metrics from a particular source' do
      message = build(:message)
  
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
end
