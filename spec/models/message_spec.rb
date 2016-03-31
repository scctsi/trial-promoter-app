require 'rails_helper'

describe Message do
  it { is_expected.to validate_presence_of(:text) }
  it { is_expected.to belong_to :clinical_trial }
  it { is_expected.to belong_to :message_template }
  it { should enumerize(:status).in(:new, :sent_to_buffer).with_default(:new).with_predicates(true) }
  it { should have_one(:buffer_update) }
  it { should have_many(:metrics) }

  it "can store an array of Buffer profiles ids" do
    message = Message.new(text: 'Some text')
    message.buffer_profile_ids = ["1234abcd", "1234efgh", "1234ijkl"]
    
    message.save
    message.reload
    
    expect(message.buffer_profile_ids).to eq(["1234abcd", "1234efgh", "1234ijkl"])
  end
  
  it "always updates the metrics from a particular source if metrics from that source already exist" do
    message = Message.new
    
    message.metrics << Metric.new(source: :facebook, data: {"likes": 1})
    message.metrics << Metric.new(source: :facebook, data: {"likes": 2})

    expect(message.metrics.length).to eq(1)
    expect(message.metrics[0].data[:likes]).to eq(2)
  end
  
  it "only allows metrics from buffer and the specific platform that the message is going to be posted on" do
    skip "Test this later."
  end
  
  describe "query functions" do
    before do
      @messages = build_list(:message, 5)
      @messages[0].buffer_update = BufferUpdate.new(:buffer_id => "buffer1", :status => :sent, :service_update_id => 'service1')
      @messages[0].save
      @messages[1].buffer_update = BufferUpdate.new(:buffer_id => "buffer2", :status => :sent, :service_update_id => 'service2')
      @messages[1].save
      @messages[2].buffer_update = BufferUpdate.new(:buffer_id => "buffer3", :status => :pending, :service_update_id => nil)
      @messages[2].save
    end
    
    it "finds the message that has a specific service update id" do
      message = Message.find_by_service_update_id('service2')
      
      expect(message).not_to be_nil
      expect(message.buffer_update.service_update_id).to eq('service2')
    end

    it "returns nil if no message exists for a specific service update id" do
      message = Message.find_by_service_update_id('unknown')
      
      expect(message).to be_nil
    end
  end
end
