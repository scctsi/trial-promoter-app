class ClickMeterClient
  include HTTParty
  
  # This class is a facade to the Click Meter API
  def self.post_request_body_for_create_tracking_link(group_id, url, title, name)
    post_request_body = {}
    
    # REF: https://support.clickmeter.com/hc/en-us/articles/211036826-How-to-create-a-tracking-link
    # title is the name used in the dashboard of ClickMeter for the created link
    # name is used in the tracking link. e.g.: http://trk.as/name
    post_request_body["type"] = 0
    post_request_body["title"] = title
    post_request_body["groupId"] = group_id
    post_request_body["name"] = name
    post_request_body["typeTL"] = { "domainId" => 1501, "redirectType" => 301, "url" => url }
    
    post_request_body
  end
  
  def self.create_tracking_link(group_id, url, title, name)
    p post_request_body_for_create_tracking_link(group_id, url, title, name)
    response = post('http://apiv2.clickmeter.com:80/datapoints', :body => post_request_body_for_create_tracking_link(group_id, url, title, name).to_json, :headers => { 'Content-Type' => 'application/json; charset=UTF-8', 'X-Clickmeter-Authkey' => Setting[:click_meter_api_key]} )
  end
end