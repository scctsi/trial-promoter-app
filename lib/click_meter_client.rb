class ClickMeterClient
  include HTTParty
  
  # This class is a facade to the Click Meter API
  def self.post_request_body_for_create_tracking_link(experiment, message)
    post_request_body = {}
    
    # REF: https://support.clickmeter.com/hc/en-us/articles/211036826-How-to-create-a-tracking-link
    post_request_body[:type] = '0' 
    post_request_body[:title] = message.to_param
    post_request_body[:groupId] = '572279'
    post_request_body[:name] = message.to_param
    post_request_body[:typeTL] = { domainId: '1501', redirectType: '301', url: TrackingUrl.campaign_url(message) }
    
    post_request_body  
  end
  
  def self.create_tracking_link(experiment, message)
    response = get('http://apiv2.clickmeter.com:80/datapoints', :headers => { 'Content-Type' => 'application/json; charset=UTF-8', 'X-Clickmeter-Authkey' => Setting[:click_meter_api_key]} )
  end
end