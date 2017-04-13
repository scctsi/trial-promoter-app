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
    # Non-existant tracking link?
    return nil if response.parsed_response['httpErrorCode'] && response.parsed_response['httpErrorCode'] == 404
    # Deleted link?
    return nil if response.parsed_response['status'] && response.parsed_response['status'] == 3
    
    click_meter_tracking_link = ClickMeterTrackingLink.new
    click_meter_tracking_link.click_meter_id = response.parsed_response["id"]
    # This code needs testing. Is the Click Meter response sometimes inconsistent in case?
    click_meter_tracking_link.tracking_url = response.parsed_response["trackingCode"] if !response.parsed_response["trackingCode"].nil?
    click_meter_tracking_link.tracking_url = response.parsed_response["trackingcode"] if !response.parsed_response["trackingcode"].nil?
    click_meter_tracking_link.destination_url = response.parsed_response["typeTL"]["url"] if !response.parsed_response["typeTL"].nil?
    click_meter_tracking_link.destination_url = response.parsed_response["typetL"]["url"] if !response.parsed_response["typetL"].nil?
    click_meter_tracking_link.destination_url = response.parsed_response["typeTl"]["url"] if !response.parsed_response["typeTl"].nil?
    click_meter_tracking_link.destination_url = response.parsed_response["typetl"]["url"] if !response.parsed_response["typetl"].nil?
    
    p response.parsed_response if click_meter_tracking_link.destination_url.nil? || click_meter_tracking_link.tracking_url.nil?

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
  
  def self.delete_tracking_link(tracking_link_id)
    delete("http://apiv2.clickmeter.com:80/datapoints/#{tracking_link_id}", :headers => { 'Content-Type' => 'application/json; charset=UTF-8', 'X-Clickmeter-Authkey' => Setting[:click_meter_api_key]} )
  end
  
  def self.get_groups
    # Click Meter API key not set?
    return [] if Setting[:click_meter_api_key].blank?
    groups = []
    
    response = get("http://apiv2.clickmeter.com:80/groups", :headers => { 'Content-Type' => 'application/json; charset=UTF-8', 'X-Clickmeter-Authkey' => Setting[:click_meter_api_key]} )
    
    response.parsed_response["entities"].each do |group|
      group_details = get("http://apiv2.clickmeter.com:80/groups/#{group["id"]}", :headers => { 'Content-Type' => 'application/json; charset=UTF-8', 'X-Clickmeter-Authkey' => Setting[:click_meter_api_key]} )
      if group_details["deleted"] != true
        groups << OpenStruct.new(id: group_details["id"], name: group_details["name"])
      end
    end
    
    groups
  end

  def self.get_domains
    # Click Meter API key not set?
    return [] if Setting[:click_meter_api_key].blank?
    domains = []

    # Get both system and dedicated domains 
    ["http://apiv2.clickmeter.com:80/domains", "http://apiv2.clickmeter.com:80/domains?type=dedicated"].each do |request_url|
      response = get(request_url, :headers => { 'Content-Type' => 'application/json; charset=UTF-8', 'X-Clickmeter-Authkey' => Setting[:click_meter_api_key]} )
      
      response.parsed_response["entities"].each do |domain|
        domain_details = get("http://apiv2.clickmeter.com:80/domains/#{domain["id"]}", :headers => { 'Content-Type' => 'application/json; charset=UTF-8', 'X-Clickmeter-Authkey' => Setting[:click_meter_api_key]} )
        domains << OpenStruct.new(id: domain_details["id"], name: domain_details["name"])
      end
    end
    
    domains << OpenStruct.new(id: 1501, name: '9nl.es')
    domains
  end
  
  def self.create_click_meter_tracking_link(message, group_id, domain_id)
    if Rails.env.test?  # Create a "fake" Click Meter tracking link on test environment
      message.click_meter_tracking_link = ClickMeterTrackingLink.new
      message.click_meter_tracking_link.click_meter_id = message.id.to_s
      message.click_meter_tracking_link.click_meter_uri = "/datapoints/#{message.id}"
      message.click_meter_tracking_link.tracking_url = "http://development.tracking-domain.com/#{BijectiveFunction.encode(message.id)}"
      message.click_meter_tracking_link.destination_url = TrackingUrl.campaign_url(message)
      message.save
      message.click_meter_tracking_link.save
      return
    end

    click_meter_tracking_link = create_tracking_link(group_id, domain_id, TrackingUrl.campaign_url(message), message.to_param, BijectiveFunction.encode(message.id))
    message.click_meter_tracking_link = click_meter_tracking_link
    message.save
    message.click_meter_tracking_link.save
  end
end
