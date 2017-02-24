require 'rails_helper'

RSpec.describe SocialMediaProfilePicker do
  before do
    @social_media_profile_picker = SocialMediaProfilePicker.new
    @social_media_profiles = create_list(:social_media_profile, 4)
    @social_media_profiles[0].platform = :twitter
    @social_media_profiles[0].allowed_mediums = [:ad]
    @social_media_profiles[1].platform = :twitter
    @social_media_profiles[1].allowed_mediums = [:organic]
    @social_media_profiles[2].platform = :facebook
    @social_media_profiles[2].allowed_mediums = [:ad]
    @social_media_profiles[3].platform = :facebook
    @social_media_profiles[3].allowed_mediums = [:organic]
  end
  
  describe 'picking social media profiles for a message' do
    it 'picks a single profile given a message and a collection of social media profiles' do
      message = build(:message)
      message.message_template.platform = :twitter
      message.medium = :ad
      
      picked_profile = @social_media_profile_picker.pick(@social_media_profiles, message)
      
      expect(picked_profile).to eq(@social_media_profiles[0])
    end

    it 'returns nil when asked to pick a social profile for an organic Instagram message (since we do not support organic Instagram messages)' do
      message = build(:message)
      message.message_template.platform = :instagram
      message.medium = :organic
      
      picked_profile = @social_media_profile_picker.pick(@social_media_profiles, message)
      
      expect(picked_profile).to eq(nil)
    end

    it 'raises an error if it cannot find any suitable social media profiles for a messsage' do
      message = build(:message)
      message.message_template.platform = :instagram
      message.medium = :ad
      
      expect{ @social_media_profile_picker.pick(@social_media_profiles, message) }.to raise_error NoSuitableSocialMediaProfileError
    end
  end
end