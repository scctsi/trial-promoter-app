require 'rails_helper'

RSpec.describe SocialMediaPoster do
  before do
    @social_media_poster = SocialMediaPoster.new
  end

  it 'gets a Buffer supplied profile id given a formatted Twitter account username (Format: @username)' do
    VCR.use_cassette("social_media_poster/get_buffer_profile_id") do
      buffer_profile_id = @social_media_poster.get_buffer_profile_id('@SoCalCTSI')

      expect(buffer_profile_id).to eq('********')
    end
  end

  it 'gets a Buffer supplied profile id given a formatted Twitter account username (Format: @username) and ignores the case' do
    VCR.use_cassette("social_media_poster/get_buffer_profile_id") do
      buffer_profile_id = @social_media_poster.get_buffer_profile_id('@socalctsi')

      expect(buffer_profile_id).to eq('********')
    end
  end

  it 'gets a Buffer supplied profile id given a Twitter account username (Format: username)' do
    VCR.use_cassette("social_media_poster/get_buffer_profile_id") do
      buffer_profile_id = @social_media_poster.get_buffer_profile_id('socalctsi')

      expect(buffer_profile_id).to eq('********')
    end
  end
end
