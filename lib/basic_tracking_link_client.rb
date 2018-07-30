class BasicTrackingLinkClient
  include HTTParty
  # TODO: Test this class!
  def self.post_request_body_for_create_tracking_link(group_id, domain_id, url, title, name)
    # Do nothing
  end

  def self.get_tracking_link(experiment, tracking_link_id)
    return nil # This client does not get any analytics for tracking links
  end

  def self.update_tracking_link(experiment, tracking_link)
    # No need to do anything
  end

  def self.create_tracking_link(experiment, group_id, domain_id, url, title, name)
    click_meter_tracking_link = ClickMeterTrackingLink.new
    
    click_meter_tracking_link.click_meter_id = title
    click_meter_tracking_link.click_meter_uri = url
    click_meter_tracking_link.tracking_url = url
    click_meter_tracking_link.destination_url = url

    click_meter_tracking_link
  end

  def self.delete_tracking_link(experiment, tracking_link_id)
    # No need to delete anything since this client does not create a tracking link on ClickMeter
  end

  def self.get_groups(experiment)
    return []
  end

  def self.get_domains(experiment)
    return []
  end

  def self.create_click_meter_tracking_link(experiment, message, group_id, domain_id)
    click_meter_tracking_link = create_tracking_link(experiment, group_id, domain_id, TrackingUrl.campaign_url(message), message.to_param, BijectiveFunction.encode(message.id))
    message.click_meter_tracking_link = click_meter_tracking_link
    message.save
    message.click_meter_tracking_link.save
  end

  def self.get_clicks(experiment, tracking_link, exclude_ip_address_list = [])
    return []
  end
end
