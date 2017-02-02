class ExperimentValidator < ActiveModel::Validator
  def validate(record)
    return if record.message_generation_parameter_set.nil?
    if record.social_media_profiles.to_a.reject!{ |social_media_profile| social_media_profile.allowed_mediums.nil? }.length == 0
      return if !(record.social_media_profiles.count == 0)
    end
    # if user selects a platform not available in the associated social media profiles
    # available_social_media_platforms = record.social_media_profiles.map { |social_media_profile| social_media_profile.platform}

    available_social_media_platforms = record.social_media_profiles.map(&:platform).uniq
    available_mediums = record.social_media_profiles.map(&:allowed_mediums).map{ |medium| medium[0] }.uniq
    required_social_media_platforms = record.message_generation_parameter_set.social_network_choices
    required_mediums = record.message_generation_parameter_set.medium_choices

    # if user has selected a platform that is not available in the associated social media profile(s)
    if !available_social_media_platforms.any? { |available_social_media_platform| required_social_media_platforms.include?(available_social_media_platform) }
      record.errors[:social_media_profiles] << 'requires social media platform(s) to match the selected social media profile.'
    end

    # # if user selects organic medium for Instagram, validation below is ignored
    if !available_mediums.any? { |available_medium| required_mediums.include?(available_medium) }
      record.errors[:social_media_profiles] << 'requires social media medium(s) to match the selected social media profile.'
    end

    # if user has not selected any social media profile to associate with the experiment
    if record.social_media_profiles.count == 0
      record.errors[:social_media_profiles] << 'requires at least one selected social media profile.'
      return
    end
  end
end