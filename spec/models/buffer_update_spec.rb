# == Schema Information
#
# Table name: buffer_updates
#
#  id                  :integer          not null, primary key
#  buffer_id           :string
#  service_update_id   :string
#  status              :string
#  message_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  sent_from_date_time :datetime
#  published_text      :text
#

require 'rails_helper'

RSpec.describe BufferUpdate, type: :model do
  it { is_expected.to validate_presence_of :buffer_id }
  it { is_expected.to enumerize(:status).in(:pending, :sent).with_default(:pending).with_predicates(true) }
  it { is_expected.to belong_to(:message) }
  
  it 'triggers a callback when destroyed' do
    buffer_update = build(:buffer_update)
    allow(buffer_update).to receive(:delete_buffer_update)

    buffer_update.destroy

    expect(buffer_update).to have_received(:delete_buffer_update)
  end
  
  it 'asks Buffer to delete the corresponding update during the destroy callback' do
    buffer_update = build(:buffer_update)
    allow(BufferClient).to receive(:delete_update)

    buffer_update.delete_buffer_update

    expect(BufferClient).to have_received(:delete_update).with(buffer_update.buffer_id)
  end
end
