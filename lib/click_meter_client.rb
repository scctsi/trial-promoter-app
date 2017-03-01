class ClickMeterClient
  include HTTParty
  
  # This class is a facade to the Click Meter API
  def self.post_request_body_for_create_tracking_link(group_id, domain_id, url, title, name)
    post_request_body = {}
    
    # REF: https://support.clickmeter.com/hc/en-us/articles/211036826-How-to-create-a-tracking-link
    # group_id is the ID of the campaign within Clickmeter
    # domain_id is the domain on which to create the tracking link. 1501 is the domainId of 9nl.es (provided by Clickmeter)
    # title is the name used in the dashboard of ClickMeter for the created link
    # name is used in the tracking link. e.g.: http://trk.as/name
    post_request_body["type"] = 0
    post_request_body["title"] = title
    post_request_body["groupId"] = group_id
    post_request_body["name"] = name
    post_request_body["typeTL"] = { "domainId" => domain_id, "redirectType" => 301, "url" => url }
    
    post_request_body
  end

  def self.get_tracking_link(tracking_link_id)
    response = get("http://apiv2.clickmeter.com:80/datapoints/#{tracking_link_id}", :headers => { 'Content-Type' => 'application/json; charset=UTF-8', 'X-Clickmeter-Authkey' => Setting[:click_meter_api_key]} )
    
    click_meter_tracking_link = ClickMeterTrackingLink.new
    click_meter_tracking_link.click_meter_id = response.parsed_response["id"]
    click_meter_tracking_link.tracking_url = response.parsed_response["trackingCode"]
    click_meter_tracking_link.destination_url = response.parsed_response["typeTL"]["url"]
    
    click_meter_tracking_link
  end
  
  def self.create_tracking_link(group_id, domain_id, url, title, name)
    response = post('http://apiv2.clickmeter.com:80/datapoints', :body => post_request_body_for_create_tracking_link(group_id, domain_id, url, title, name).to_json, :headers => { 'Content-Type' => 'application/json; charset=UTF-8', 'X-Clickmeter-Authkey' => Setting[:click_meter_api_key]} )
    
    # Raise error if name already exists on the domain with the specified name
    if response.parsed_response["errors"]
      if response.parsed_response["errors"][0]["property"] == "Name"
        raise ClickMeterTrackingLinkNameExistsError.new(name, domain_id)
      end
    end
    
    click_meter_tracking_link = get_tracking_link(response.parsed_response["id"])
    click_meter_tracking_link.click_meter_uri = response.parsed_response["uri"]
    
    click_meter_tracking_link
  end
  
  def self.create_click_meter_tracking_link(message, group_id, domain_id)
    click_meter_tracking_link = create_tracking_link(group_id, domain_id, TrackingUrl.campaign_url(message), message.to_param, BijectiveFunction.encode(message.id))
    message.click_meter_tracking_link = click_meter_tracking_link
    message.save
  end
end