class TrackingUrl
  def self.utm_parameters(message)
    utm_parameters = {}
    
    utm_parameters[:source] = message.message_template.platform.to_s
    utm_parameters[:source] = message.message_template.platform.to_s
    utm_parameters[:campaign] = message.message_generating.to_param
    utm_parameters[:term] = nil
    utm_parameters[:content] = message.to_param
    
    utm_parameters
  end

  def self.campaign_url(message)
    "#{message.promotable.url}?utm_source=#{utm_parameters(message)[:source]}&utm_campaign=#{utm_parameters(message)[:campaign]}&utm_medium=#{utm_parameters(message)[:medium]}&utm_term=#{utm_parameters(message)[:term]}&utm_content=#{utm_parameters(message)[:content]}"
  end
end