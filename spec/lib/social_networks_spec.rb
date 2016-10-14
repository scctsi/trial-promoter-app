require 'rails_helper'

RSpec.describe SocialNetworks do
  it 'support Facebook' do
    expect(SocialNetworks::SUPPORTED_NETWORKS).to include(:facebook)
  end
  
  it 'support Instagram' do
    expect(SocialNetworks::SUPPORTED_NETWORKS).to include(:instagram)
  end

  it 'support Twitter' do
    expect(SocialNetworks::SUPPORTED_NETWORKS).to include(:twitter)
  end
end