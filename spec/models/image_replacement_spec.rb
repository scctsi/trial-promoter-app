require 'rails_helper'

RSpec.describe ImageReplacement do
  it { is_expected.to belong_to(:message) }
  it { is_expected.to belong_to(:previous_image) }
  it { is_expected.to belong_to(:replacement_image) }
  it { is_expected.to validate_presence_of(:message) }
  it { is_expected.to validate_presence_of(:previous_image) }
  it { is_expected.to validate_presence_of(:replacement_image) }
end
