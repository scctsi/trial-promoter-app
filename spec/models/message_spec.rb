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
  it { is_expected.to belong_to :social_media_profile }

  it 'returns the medium as a sumbol' do
    message = build(:message)
    message.medium = :ad
    
    expect(message.medium).to be :ad
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
