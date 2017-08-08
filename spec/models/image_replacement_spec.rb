# == Schema Information
#
# Table name: image_replacements
#
#  id                   :integer          not null, primary key
#  message_id           :integer
#  previous_image_id    :integer
#  replacement_image_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'rails_helper'

RSpec.describe ImageReplacement do
  it { is_expected.to belong_to(:message) }
  it { is_expected.to belong_to(:previous_image) }
  it { is_expected.to belong_to(:replacement_image) }
  it { is_expected.to validate_presence_of(:message) }
  it { is_expected.to validate_presence_of(:previous_image) }
  it { is_expected.to validate_presence_of(:replacement_image) }
end
