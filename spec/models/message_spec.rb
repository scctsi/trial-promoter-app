require 'rails_helper'

describe Message do
  it { is_expected.to validate_presence_of(:text) }
  it { is_expected.to belong_to :clinical_trial }
  it { is_expected.to belong_to :message_template }
  it { should enumerize(:status).in(:new, :sent_to_buffer).with_default(:new).with_predicates(true) }
  it { should have_one(:buffer_update) }
  it { should have_many(:statistics) }

  it "can store an array of Buffer profiles ids" do
    message = Message.new(text: 'Some text')
    message.buffer_profile_ids = ["1234abcd", "1234efgh", "1234ijkl"]
    
    message.save
    message.reload
    
    expect(message.buffer_profile_ids).to eq(["1234abcd", "1234efgh", "1234ijkl"])
  end
  
  it "always updates statistics from the same source if statistics from that source already exist" do
    message = Message.new
    
    message.statistics << Statistic.new(source: :facebook, data: {"likes": 1})
    message.statistics << Statistic.new(source: :facebook, data: {"likes": 2})

    expect(message.statistics.length).to eq(1)
    expect(message.statistics[0].data[:likes]).to eq(2)
  end
  
  it "only allows statistics from buffer and the specific platform that the message is going to be posted on" do
    skip "Test this later."
  end
end
