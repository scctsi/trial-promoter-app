class SocialMediaProfilePicker
  def pick(social_media_profiles, platform, medium)
    suitable_profiles = social_media_profiles.select{ |social_media_profile| platform == social_media_profile.platform && social_media_profile.allowed_mediums.include?(medium) }
    suitable_profiles = [nil] if platform == :instagram and medium == :organic
    raise NoSuitableSocialMediaProfileError if suitable_profiles.length == 0
    suitable_profiles[0]
  end
end