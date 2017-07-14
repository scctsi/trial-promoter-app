require 'rails_helper'

RSpec.describe Modification, type: :model do
  it { is_expected.to belong_to(:experiment) }
  it { is_expected.to validate_presence_of(:experiment) }
end
