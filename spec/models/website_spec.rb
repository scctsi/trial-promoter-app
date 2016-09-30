require 'rails_helper'

describe Website do
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :url }

  it { is_expected.to have_many(:messages) }
  it { is_expected.to have_and_belong_to_many(:experiments) }
end
