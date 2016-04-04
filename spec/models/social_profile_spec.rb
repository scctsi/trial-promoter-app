require 'rails_helper'

describe SocialProfile do
  it { is_expected.to validate_presence_of(:network_name) }
  it { is_expected.to validate_presence_of(:username) }
end
