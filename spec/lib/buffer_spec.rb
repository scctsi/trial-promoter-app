require 'rails_helper'

RSpec.describe Buffer do
  before do
    allow(Figaro.env).to receive(:buffer_access_token).and_return("1/2852dbc6f3e36697fed6177f806a2b2f")
    allow(Buffer).to receive(:post).and_call_original
    allow(Buffer).to receive(:get).and_call_original
    @message = Message.new(:buffer_profile_ids => ['53275ff6c441ced7264e4ca5'], :text => "Some text")
  end
  
  it "returns the body of the POST request for creating a Buffer update via the Buffer API" do
    post_request_body = Buffer.post_request_body_for_create(@message)
    
    expect(post_request_body[:profile_ids]).to eq(@message.buffer_profile_ids)
    expect(post_request_body[:text]).to eq(@message.text)
    expect(post_request_body[:shorten]).to eq(true)
    expect(post_request_body[:access_token]).to eq(Figaro.env.buffer_access_token)
  end
  
  it "uses the Buffer API to create an update" do
    VCR.use_cassette 'buffer/create_update' do
      Buffer.create_update(@message)
    end

    expect(Buffer).to have_received(:post).with('https://api.bufferapp.com/1/updates/create.json', {:body => Buffer.post_request_body_for_create(@message)})
    expect(@message.buffer_update).not_to be_nil
    # The response returned from Buffer contains an ID that we need to store in a newly created buffer_update
    expect(@message.buffer_update.buffer_id).to eq('56f599e00df548cf14099c86')
    # The message and the new Buffer update should be persisted
    expect(@message.persisted?).to be_truthy
    expect(@message.buffer_update.persisted?).to be_truthy
  end
  
  it "uses the Buffer API to get an update to the status (pending, sent) of a BufferUpdate and simultaneously updates the statistics for the corresponding message" do
    buffer_id = '55f8a111b762b0cf06d79116'
    @message.buffer_update = BufferUpdate.new(:buffer_id => buffer_id)

    VCR.use_cassette 'buffer/get_update' do
      Buffer.get_update(@message)
    end
    
    expect(Buffer).to have_received(:get).with("https://api.bufferapp.com/1/updates/#{buffer_id}.json?access_token=#{Figaro.env.buffer_access_token}")
    expect(@message.buffer_update.status).to eq(:sent)
    expect(@message.statistics.length).not_to eq(0)
    expect(@message.statistics[0].source).to eq(:buffer)
    expect(@message.statistics[0].data).not_to eq(0)
    # The call should have automatically saved both the message and the new Buffer update
    expect(@message.persisted?).to be_truthy
    expect(@message.buffer_update.persisted?).to be_truthy
  end
end