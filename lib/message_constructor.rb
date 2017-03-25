class MessageConstructor
  def construct(message_generating_instance, message_template, platform, medium, social_media_profile, date = nil, time_hash = nil, hashtags = nil)
    # A message_generating_instance is either an Experiment or Campaign, the two models that can generate messages.
    message = Message.new(content: message_template.content)
    
    # Set all associations so that we can trace the exact context in which a message was constructed.
    message.promoted_website_url = message_template.promoted_website_url
    message.message_generating = message_generating_instance
    message.message_template = message_template
    message.platform = platform
    message.medium = medium
    message.social_media_profile = social_media_profile
    message.scheduled_date_time = DateTime.new(date.year, date.month, date.day, time_hash[:hour], time_hash[:minute], 0) if date != nil && time_hash != nil
    message.scheduled_date_time = ActiveSupport::TimeZone.new("America/Los_Angeles").local_to_utc(message.scheduled_date_time)
    if !hashtags.nil?
      if message.platform == :twitter
        fittable_hashtags = MessageConstructor.fittable_hashtags(message.content, hashtags) 
        message.content += fittable_hashtags.sample if fittable_hashtags.length > 0
      else
        message.content += hashtags.sample if !hashtags.nil? and hashtags.length > 0
      end
    end
    message
  end
  
  def replace_url_variable(message, url)
    index_of_url_variable = message.content.index('{url}')
    return if index_of_url_variable.nil?
    
    if message.content[index_of_url_variable + 5] != ' ' and !message.content[index_of_url_variable + 5].nil?
      message.content.gsub!('{url}', url + ' ')
    else
      message.content.gsub!('{url}', url)
    end
  end

  def self.fittable_hashtags(content, hashtags)
    twitter_message_content = content.gsub('{url}', '')
    return_value = []
    
    hashtags.each do |hashtag|
      return_value << hashtag if twitter_message_content.length <= (140 - 23 - hashtag.length)
    end

    return_value    
  end
  
  def self.unfittable_hashtags(content, hashtags)
    return hashtags - fittable_hashtags(content, hashtags)
  end
end