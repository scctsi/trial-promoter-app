require 'rails_helper'

RSpec.describe TrialPromoter do
  it 'supports Facebook' do
    expect(TrialPromoter::SUPPORTED_NETWORKS).to include(:facebook)
  end
  
  it 'supports Instagram' do
    expect(TrialPromoter::SUPPORTED_NETWORKS).to include(:instagram)
  end

  it 'supports Twitter' do
    expect(TrialPromoter::SUPPORTED_NETWORKS).to include(:twitter)
  end
  
  describe 'supports?' do
    it 'returns true if a social network (passed in as a symbol) is supported' do
      expect(TrialPromoter.supports?(:facebook)).to be true
    end
    
    it 'returns true if a social network (passed in as a symbol with a different case) is supported' do
      expect(TrialPromoter.supports?(:FACEBOOK)).to be true
    end

    it 'returns true if a social network (passed in as a string) is supported' do
      expect(TrialPromoter.supports?("facebook")).to be true
    end

    it 'returns true if a social network (passed in as a string with a different case) is supported' do
      expect(TrialPromoter.supports?("Facebook")).to be true
    end

    it 'returns true if a social network (passed in as a string with a different case and surrounding whitespace) is supported' do
      expect(TrialPromoter.supports?("  Facebook  ")).to be true
    end

    it 'returns false if a social network is not supported' do
      expect(TrialPromoter.supports?("  NotSupported  ")).to be false
    end
  end
end