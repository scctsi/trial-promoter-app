class ExperimentValidator < ActiveModel::Validator
  def validate(record)
    return if record.message_generation_parameter_set.nil?

    # if user selects a platform not available in the associated social media profiles
    # available_social_media_platforms = record.social_media_profiles.map { |social_media_profile| social_media_profile.platform}
    available_social_media_platforms = record.social_media_profiles.map(&:platform)
    # p available_social_media_platforms
    available_mediums = record.social_media_profiles.map(&:allowed_mediums).map{ |allowed_mediums| allowed_mediums[0] }
    p available_mediums
    required_social_media_platforms = record.message_generation_parameter_set.social_network_choices
    # p required_social_media_platforms
    required_mediums = record.message_generation_parameter_set.medium_choices
    # p required_mediums
    p '------'
    profile_grid = []

    # if user has not selected any social media profile to associate with the experiment
    if available_social_media_platforms.count == 0
      record.errors[:social_media_profiles] << 'requires at least one selected social media profile.'
      return
    end

    # if user has selected a platform that is not available in the associated social media profile(s)
    if !available_social_media_platforms.include?(required_social_media_platforms)
      record.errors[:social_media_profiles] << 'requires social media platform(s) to match the selected social media profile.'
      return
    end

    # # if user selects organic medium for Instagram, validation below is ignored
    # if (available_social_media_platforms.include?(:instagram) && (required_social_media_platforms).include?(:instagram) && required_mediums.include?(:organic))

    # # if user selects a medium that is not available in the associated social media profile(s)
    # els

    if !available_mediums.include?(required_mediums)
      record.errors[:social_media_profiles] << 'requires social media medium(s) to match the selected social media profile.'
      return
    end
  end
end