class BufferClient
  include HTTParty

  # This class is a facade to the Buffer API
  def self.post_request_body_for_create(experiment, message)
    # REF: https://buffer.com/developers/api/updates#updatescreate
    request_body = {
      :profile_ids => message.social_media_profile.buffer_id,
      :text => message.content,
      :shorten => true,
      :access_token => experiment.settings(:buffer).api_key
    }

    request_body[:media] = {"thumbnail" => message.image.url, "photo" => message.image.url} if message.image_present == :with
    request_body[:scheduled_at] = message.scheduled_date_time.to_s if !message.scheduled_date_time.nil?

    request_body
  end

  def self.get_social_media_profiles(experiment)
    response = get("https://api.bufferapp.com/1/profiles.json?access_token=#{experiment.settings(:buffer).api_key}")
    response.parsed_response.each do |social_media_profile|
      if SocialMediaProfile.find_by(buffer_id: social_media_profile["_id"]).nil?
        SocialMediaProfile.create!(buffer_id: social_media_profile["_id"],
                                    platform: social_media_profile["service"].to_sym,
                                    service_id: social_media_profile["service_id"].to_sym,
                                    service_type: social_media_profile["service_type"].to_sym,
                                    service_username: social_media_profile["service_username"].to_sym)
      end
    end
  end

  def self.get_update(experiment, message)
    response = get("https://api.bufferapp.com/1/updates/#{message.buffer_update.buffer_id}.json?access_token=#{experiment.settings(:buffer).api_key}")
    if response.parsed_response["status"] == 'sent'
      message.buffer_update.status = :sent
      sent_time = Time.at(response.parsed_response["sent_at"])
      message.buffer_update.sent_from_date_time = sent_time if message.buffer_update.status == 'sent'
      message.buffer_update.service_update_id = response.parsed_response["service_update_id"]
      # It's usually a bad idea to do what we do in the next line, namely copy the service_update_id to the message (the service_update_id is no longer DRY, it is repeated in two models).
      # However it makes sense in this case, because 1) it's convenient to access the social_network_id from the message and 2) the social_network_id should remain unchanged for ever.
      message.social_network_id = message.buffer_update.service_update_id
      message.metrics << Metric.new(source: :buffer, data: response.parsed_response["statistics"])
      message.publish_status = :published_to_social_network
      message.buffer_update.save
      message.save
    end
  end

  def self.create_update(experiment, message)
    response = post('https://api.bufferapp.com/1/updates/create.json', {:body => BufferClient.post_request_body_for_create(experiment, message)})

    # Handle failures
    if response.parsed_response['success'] == false
      case response.parsed_response['code']
      when 1034 # Update was scheduled for the past, ignore!
        return
      when 1004
        raise MessageTooLongForTwitterError.new(message.id)
      end
    end

    buffer_update = BufferUpdate.new(:buffer_id => response.parsed_response["updates"][0]["id"], :published_text => response.parsed_response["updates"][0]["text"])
    message.buffer_update = buffer_update
    message.publish_status = :published_to_buffer
    message.save
  end

  def self.delete_update(buffer_id)
    post("https://api.bufferapp.com/1/updates/#{buffer_id}/destroy.json")
  end
end