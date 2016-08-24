require 'rails_helper'

RSpec.describe BufferUpdate, type: :model do
  it { is_expected.to validate_presence_of :buffer_id }
  it { is_expected.to enumerize(:status).in(:pending, :sent).with_default(:pending).with_predicates(true) }
  it { is_expected.to belong_to(:message) }
end