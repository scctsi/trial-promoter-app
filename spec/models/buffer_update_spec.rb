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
#

require 'rails_helper'

RSpec.describe BufferUpdate, type: :model do
  it { is_expected.to validate_presence_of :buffer_id }
  it { is_expected.to enumerize(:status).in(:pending, :sent).with_default(:pending).with_predicates(true) }
  it { is_expected.to belong_to(:message) }
end
