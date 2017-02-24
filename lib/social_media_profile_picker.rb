class SocialMediaProfilePicker
  def pick(social_media_profiles, message)
    suitable_profiles = social_media_profiles.select{ |social_media_profile| message.message_template.platform == social_media_profile.platform && social_media_profile.allowed_mediums.include?(message.medium) }
    suitable_profiles = [nil] if message.message_template.platform == :instagram and message.medium == :organic
    raise NoSuitableSocialMediaProfileError if suitable_profiles.length == 0
    suitable_profiles[0]
  end
end