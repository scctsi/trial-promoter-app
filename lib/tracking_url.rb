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
    "#{message.promoted_website_url}?utm_source=#{utm_parameters(message)[:source]}&utm_campaign=#{utm_parameters(message)[:campaign]}&utm_medium=#{utm_parameters(message)[:medium]}&utm_term=#{utm_parameters(message)[:term]}&utm_content=#{utm_parameters(message)[:content]}"
  end
end