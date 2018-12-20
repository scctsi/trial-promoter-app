require 'rails_helper'

RSpec.describe Study, type: :model do
  before do
  end

  it { is_expected.to have_many(:experiments) }
  it { is_expected.to have_many(:institutions) }
end
