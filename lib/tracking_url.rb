class TrackingUrl
  def self.utm_parameters(message)
    utm_parameters = {}
    
    utm_parameters[:source] = message.platform
    utm_parameters[:medium] = message.medium
    utm_parameters[:campaign] = message.message_generating.to_param
    utm_parameters[:term] = nil
    utm_parameters[:content] = message.to_param
    
    utm_parameters
  end

  def self.campaign_url(message)
    # Pull out any anchor link in the message's promoted website url and move it to the end of the campaign URL
    anchor_link = ''
    if !message.promoted_website_url.index('#').nil?
      anchor_link = message.promoted_website_url[message.promoted_website_url.index('#')..-1]
      # Strip out the anchor link
      message.promoted_website_url[message.promoted_website_url.index('#')..-1] = ''
    end

    "#{message.promoted_website_url}?utm_source=#{utm_parameters(message)[:source]}&utm_campaign=#{utm_parameters(message)[:campaign]}&utm_medium=#{utm_parameters(message)[:medium]}&utm_term=#{utm_parameters(message)[:term]}&utm_content=#{utm_parameters(message)[:content]}#{anchor_link}"
  end
end