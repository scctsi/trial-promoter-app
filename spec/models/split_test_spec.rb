require 'rails_helper'

RSpec.describe SplitTest, type: :model do
  it { is_expected.to belong_to(:experiment) }
  it { is_expected.to validate_presence_of(:experiment) }
  it { is_expected.to belong_to(:variation_a) }
  it { is_expected.to validate_presence_of(:variation_a) }
  it { is_expected.to belong_to(:variation_b) }
  it { is_expected.to validate_presence_of(:variation_b) }
end