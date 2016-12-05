# == Schema Information
#
# Table name: messages
#
#  id                      :integer          not null, primary key
#  clinical_trial_id       :integer
#  message_template_id     :integer
#  content                 :text
#  tracking_url            :string(2000)
#  status                  :string
#  buffer_profile_ids      :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  website_id              :integer
#  message_generating_id   :integer
#  message_generating_type :string
#

require 'rails_helper'

describe Message do
  it { is_expected.to validate_presence_of :content }
  it { is_expected.to belong_to :clinical_trial }
  it { is_expected.to belong_to :message_template }
  it { is_expected.to enumerize(:status).in(:new, :sent_to_buffer).with_default(:new).with_predicates(true) }
  it { is_expected.to have_one :buffer_update }
  it { is_expected.to have_many :metrics }
  it { is_expected.to validate_presence_of :message_generating }
  it { is_expected.to belong_to(:message_generating) }

  it 'stores an array of Buffer profiles ids' do
    message = build(:message)
    message.buffer_profile_ids = ["1234abcd", "1234efgh", "1234ijkl"]
    
    message.save
    message.reload
    
    expect(message.buffer_profile_ids).to eq(["1234abcd", "1234efgh", "1234ijkl"])
  end
  
  it 'always updates existing metrics from a particular source' do
    message = Message.new
    
    message.metrics << Metric.new(source: :facebook, data: {"likes": 1})
    message.metrics << Metric.new(source: :facebook, data: {"likes": 2})

    expect(message.metrics.length).to eq(1)
    expect(message.metrics[0].data[:likes]).to eq(2)
  end
  
  it "only allows metrics from buffer and the specific platform that the message is going to be posted on" do
    skip "Test this later."
  end
  
  describe 'querying' do
    before do
      @messages = build_list(:message, 5)
      @messages[0].buffer_update = BufferUpdate.new(:buffer_id => "buffer1", :status => :sent, :service_update_id => 'service1')
      @messages[0].save
      @messages[1].buffer_update = BufferUpdate.new(:buffer_id => "buffer2", :status => :sent, :service_update_id => 'service2')
      @messages[1].save
      @messages[2].buffer_update = BufferUpdate.new(:buffer_id => "buffer3", :status => :pending, :service_update_id => nil)
      @messages[2].save
    end
    
    it 'finds the message that has a specific service update id' do
      message = Message.find_by_service_update_id('service2')
      
      expect(message).not_to be_nil
      expect(message.buffer_update.service_update_id).to eq('service2')
    end

    it 'returns nil if no message exists for a specific service update id' do
      message = Message.find_by_service_update_id('unknown')
      
      expect(message).to be_nil
    end
  end
end
