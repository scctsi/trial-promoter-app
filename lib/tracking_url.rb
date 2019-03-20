class TrackingUrl
  def self.utm_parameters(message_or_post)
    utm_parameters = {}

    case message_or_post
      when Message
        utm_parameters[:source] = message_or_post.platform
        utm_parameters[:medium] = message_or_post.medium
        utm_parameters[:campaign] = message_or_post.message_generating.to_param
        utm_parameters[:term] = nil
        utm_parameters[:content] = message_or_post.to_param
      when Post
        utm_parameters[:source] = message_or_post.post_template.social_media_specification.platform
        utm_parameters[:medium] = message_or_post.post_template.social_media_specification.post_type
        utm_parameters[:campaign] = message_or_post.experiment.to_param
        utm_parameters[:term] = nil
        utm_parameters[:content] = message_or_post.to_param
    end
        
    return utm_parameters
  end

  def self.campaign_url(message_or_post)

    case message_or_post
      when Message
        # Pull out any anchor link in the message's promoted website url and move it to the end of the campaign URL
        anchor_link = ''
        if !message_or_post.promoted_website_url.index('#').nil?
          anchor_link = message_or_post.promoted_website_url[message_or_post.promoted_website_url.index('#')..-1]
          # Strip out the anchor link
          message_or_post.promoted_website_url[message_or_post.promoted_website_url.index('#')..-1] = ''
        end

        "#{message_or_post.promoted_website_url}?utm_source=#{utm_parameters(message_or_post)[:source]}&utm_campaign=#{utm_parameters(message_or_post)[:campaign]}&utm_medium=#{utm_parameters(message_or_post)[:medium]}&utm_term=#{utm_parameters(message_or_post)[:term]}&utm_content=#{utm_parameters(message_or_post)[:content]}#{anchor_link}"
      when Post
        # Pull out any anchor link in the posts's website url and move it to the end of the campaign URL
        anchor_link = ''
        if !message_or_post.content[:website_url].index('#').nil?
          anchor_link = message_or_post.content[:website_url][message_or_post.content[:website_url].index('#')..-1]
          # Strip out the anchor link
          message_or_post.content[:website_url][message_or_post.content[:website_url].index('#')..-1] = ''
        end

        "#{message_or_post.content[:website_url]}?utm_source=#{utm_parameters(message_or_post)[:source]}&utm_campaign=#{utm_parameters(message_or_post)[:campaign]}&utm_medium=#{utm_parameters(message_or_post)[:medium]}&utm_term=#{utm_parameters(message_or_post)[:term]}&utm_content=#{utm_parameters(message_or_post)[:content]}#{anchor_link}"
      end
  end
end