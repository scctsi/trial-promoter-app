require 'rails_helper'

RSpec.describe BufferUpdate, type: :model do
  it { should validate_presence_of :buffer_id }
  it { should enumerize(:status).in(:pending, :sent).with_default(:pending).with_predicates(true) }
  it { should belong_to(:message) }
end