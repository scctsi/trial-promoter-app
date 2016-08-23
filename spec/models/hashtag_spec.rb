require 'rails_helper'

describe Hashtag do
  it { should validate_presence_of :phrase }
  it { should validate_uniqueness_of :phrase }
end
