class ExperimentValidator < ActiveModel::Validator
  def validate(record)
    # Currently a experiment is not required to have a message generation parameter set, though this might return in the future
    return if record.message_generation_parameter_set.nil?

    # If user has not selected any social media profile to associate with the experiment
    if record.social_media_profiles.size == 0
      record.errors[:social_media_profiles] << 'requires at least one selection.'
      return
    end

    # Remove all social_media_profiles that have allowed_mediums set to nil.
    # 1) The experiment edit form will only show the user valid choices for social media profiles, so this might never actually be a problem.
    # 2) We might think about adding a validation for allowed_mediums in the future.
    record.social_media_profiles = record.social_media_profiles.to_a.reject{ |social_media_profile| social_media_profile.allowed_mediums.nil? }

    required_social_media_platforms = record.message_generation_parameter_set.social_network_choices
    associated_social_media_platforms = record.social_media_profiles.map(&:platform).uniq

    # If the experiment requires a platform that is not available in the associated social media profile(s)
    missing_platforms = required_social_media_platforms - associated_social_media_platforms
    if missing_platforms.count > 0
      record.errors[:social_media_profiles] << "requires at least one selection for #{missing_platforms.join(", ").titleize}."
      return
    end

    # If user has selected all the required platform(s), but there are medium(s) that are not available in the associated social media profile(s)
    # WARNING: This code below will only work correctly if the allowed_mediums for the social media profiles contains one choice.
    required_platform_medium_combinations = record.message_generation_parameter_set.social_network_choices.product(record.message_generation_parameter_set.medium_choices)
    associated_platform_medium_combinations = record.social_media_profiles.map { |social_media_profile| [social_media_profile.platform, social_media_profile.allowed_mediums[0]] }

    required_platform_medium_combinations.delete([:instagram, :organic]) # Trial Promoter does not support Instagram [Organic] yet
    missing_platform_medium_combinations = required_platform_medium_combinations - associated_platform_medium_combinations
    missing_platform_medium_combinations_string = missing_platform_medium_combinations.inject('') { |string, missing_platform_medium_combination| "#{missing_platform_medium_combination[0].to_s.titleize} [#{missing_platform_medium_combination[1].to_s.titleize}], #{string}" }
    missing_platform_medium_combinations_string = missing_platform_medium_combinations_string.chomp(', ')

    if missing_platform_medium_combinations.count > 0
      record.errors[:social_media_profiles] << "requires at least one selection for #{missing_platform_medium_combinations_string}."
      return
    end
    
    [record.twitter_posting_times, record.instagram_posting_times, record.facebook_posting_times].each do |posting_times|
      if !posting_times.nil? && posting_times.split(',').count != record.message_generation_parameter_set.number_of_messages_per_social_network
        record.errors[:message_generation_parameter_set] << "requires that the number of selected posting times matches the number of messages per social network per day"
        return
      end
    end
  end
end