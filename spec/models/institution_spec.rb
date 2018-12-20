require 'rails_helper'

RSpec.describe Institution, type: :model do
  before do
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to have_many(:experiments).through(:studies) }
  it { is_expected.to have_many(:studies) }
end
