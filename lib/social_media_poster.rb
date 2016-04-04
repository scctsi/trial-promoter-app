class SocialMediaPoster
  include HTTParty

  SOCIAL_MEDIA_BUFFER_PROFILE_IDS = {
    'Facebook: USC Clinical Trials Staging' => '********',
    'Facebook: USC Clinical Trials' => '********',
    'Twitter: USCTrials' => '********',
    'Twitter: TP_Staging' => '********',
    'Facebook: Boosted USC Clinical Trials' => '********',
    'Facebook: Boosted-Staging USC Clinical Trials' => '********'
  }

  def get_buffer_profile_id(formatted_twitter_username)
    # TODO: Move the Access token to secrets.yml
    http_parsed_response = self.class.get("https://api.bufferapp.com/1/profiles.json?access_token=********").parsed_response

    formatted_twitter_username = "@#{formatted_twitter_username}" if formatted_twitter_username[0] != '@'
    http_parsed_response.each do |social_profile|
      if social_profile['formatted_username'].downcase == formatted_twitter_username.downcase
        return social_profile['id']
      end
    end

    nil
  end

  def publish(message)
    # TODO: Unit test
    return if message.image_required and message.permanent_image_url.blank? # Cannot publish a message that requires an image but where no image has been set yet.

    profile_ids = []

    # Twitter
    if message.message_template.platform.start_with?('twitter')
      if message.campaign == 'trial-promoter-staging' || message.campaign == 'trial-promoter-development' # Staging
        profile_ids = [SOCIAL_MEDIA_BUFFER_PROFILE_IDS['Twitter: TP_Staging']]
      else # Production
        profile_ids = [SOCIAL_MEDIA_BUFFER_PROFILE_IDS['Twitter: USCTrials']]
      end
    end

    # Facebook
    if message.message_template.platform.start_with?('facebook')

      if message.campaign == 'trial-promoter-staging' || message.campaign == 'trial-promoter-development' # Staging

        if message.medium == 'paid' # Paid
          profile_ids = [SOCIAL_MEDIA_BUFFER_PROFILE_IDS['Facebook: Boosted-Staging USC Clinical Trials']]
        else # Organic
          profile_ids = [SOCIAL_MEDIA_BUFFER_PROFILE_IDS['Facebook: USC Clinical Trials Staging']]
        end

      else # Production

        if message.medium == 'paid' # Paid
          profile_ids = [SOCIAL_MEDIA_BUFFER_PROFILE_IDS['Facebook: Boosted USC Clinical Trials']]
        else # Organic
          profile_ids = [SOCIAL_MEDIA_BUFFER_PROFILE_IDS['Facebook: USC Clinical Trials']]
        end

      end

    end

    scheduled_date = message.scheduled_at

    # Twitter: New week days: 11;42 am, 2:05pm, 5:30pm; New weekend: 11:35am, 2:35pm, 5:30pm
    # Facebook: New week days and weekend 8:27am, 9:22am, 9:00pm
    # Facebook Boosted: New week days and weekend 8:27am, 9:22am, 9:00pm
    
    if Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 9, 00, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").saturday? or Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 9, 00, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").sunday?

      # Twitter, weekend
      # 11:35am, 2:35pm, 5:30pm
      if message.message_template.platform.start_with?('twitter')
        if !(message.image_required) and (message.message_template.platform.index('uscprofiles') == nil)
          scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 11, 35, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").utc
        elsif message.message_template.platform.index('uscprofiles') != nil
          scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 14, 35, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").utc
        else
          scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 17, 30, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").utc
        end
      end

      # Facebook, weekend
      # 8:27am, 9:22am, 9:00pm
      if message.message_template.platform.start_with?('facebook')
        if !(message.image_required) and (message.message_template.platform.index('uscprofiles') == nil)
          scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 8, 27, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").utc
        elsif message.message_template.platform.index('uscprofiles') != nil
          scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 9, 22, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").utc
        else
          scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 21, 00, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").utc
        end
      end

    else

      # Twitter, weekday
      # 11;42 am, 2:05pm, 5:30pm;
      if message.message_template.platform.start_with?('twitter')
        if !(message.image_required) and (message.message_template.platform.index('uscprofiles') == nil)
          scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 11, 42, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").utc
        elsif message.message_template.platform.index('uscprofiles') != nil
          scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 14, 05, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").utc
        else
          scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 17, 30, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").utc
        end
      end

      # Facebook, weekday
      # 8:27am, 9:22am, 9:00pm
      if message.message_template.platform.start_with?('facebook')
        if !(message.image_required) and (message.message_template.platform.index('uscprofiles') == nil)
          scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 8, 27, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").utc
        elsif message.message_template.platform.index('uscprofiles') != nil
          scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 9, 22, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").utc
        else
          scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 21, 00, 00, '-08:00').in_time_zone("Pacific Time (US & Canada)").utc
        end
      end

    end

    # TODO: Unit test
    if (message.image_required) # Post with image
      body = {
          :text => message.content,
          :profile_ids => profile_ids,
          :access_token => '********',
          :scheduled_at => scheduled_at,
          :media => { :photo => message.permanent_image_url, :thumbnail => message.thumbnail_url }
      }
    else
      body = {
          :text => message.content,
          :profile_ids => profile_ids,
          :access_token => '********',
          :scheduled_at => scheduled_at
      }
    end

    http_parsed_response = self.class.post('https://api.bufferapp.com/1/updates/create.json', {:body => body}).parsed_response

    p http_parsed_response

    message.buffer_update_id = http_parsed_response['updates'][0]['id']
    message.sent_to_buffer_at = Time.now
    message.save
  end

  def publish_pending(platform, medium)
    messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ? and DATE(messages.scheduled_at) <= ? and messages.sent_to_buffer_at is null", platform, medium, (Time.now + 7.days).utc.to_date)

    messages.each do |message|
      publish(message)
    end

    return messages.count
  end
end