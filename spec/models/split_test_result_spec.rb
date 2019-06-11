require 'rails_helper'

RSpec.describe SplitTestResult, type: :model do
  it { is_expected.to belong_to(:split_test) }
  it { is_expected.to validate_presence_of(:split_test) }
  it { is_expected.to belong_to(:winning_variation) }
  it { is_expected.to belong_to(:losing_variation) }
end