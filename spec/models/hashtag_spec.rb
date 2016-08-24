require 'rails_helper'

describe Hashtag do
  it { is_expected.to validate_presence_of :phrase }
  it { is_expected.to validate_uniqueness_of :phrase }
end
