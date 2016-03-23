require 'rails_helper'

RSpec.describe BufferPostingManager do
  it '' do
  end
  
  # it 'publishes an update using Buffer' do
  #  allow(@publicist).to receive(:get_buffer_profile_ids).and_return(['53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5'])
  #  update = FactoryGirl.create(:update)
  #  body = {
  #      :text => update.text,
  #      :profile_ids => ['53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5'],
  #      :scheduled_at => nil,
  #      :access_token => "1/2852dbc6f3e36697fed6177f806a2b2f"
  #  }
  #  expect(Publicist).to receive(:post).with('https://api.bufferapp.com/1/updates/create.json', {:body => body})
  #
  #  @publicist.publish(update)
  # end
end