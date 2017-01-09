class Buffer
  include HTTParty
  
  # This class is a facade to the Buffer API
  def self.post_request_body_for_create(message)
    # https://buffer.com/developers/api/updates#updatescreate
    {
      :profile_ids => message.buffer_profile_ids,
      :text => message.content,
      :shorten => true,
      :access_token => Setting[:buffer_access_token]
    }
  end
  
  def self.get_social_media_profiles
    response = get("https://api.bufferapp.com/1/profiles.json?access_token=#{Setting[:buffer_access_token]}")
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
  
  def self.get_update(message)
    response = get("https://api.bufferapp.com/1/updates/#{message.buffer_update.buffer_id}.json?access_token=#{Setting[:buffer_access_token]}")
    message.buffer_update.status = response.parsed_response["status"]
    message.buffer_update.service_update_id = response.parsed_response["service_update_id"]
    # It's usually a bad idea to do what we do in the next line, namely copy the service_update_id to the message. 
    # However it makes sense in this case, because 1) it's convenient to access the social_network_id from the message and 2) the social_network_id should remain unchanged for ever.
    message.social_network_id = message.buffer_update.service_update_id
    message.metrics << Metric.new(source: :buffer, data: response.parsed_response["statistics"])
    message.save
  end
  
  def self.create_update(message)
    response = post('https://api.bufferapp.com/1/updates/create.json', {:body => Buffer.post_request_body_for_create(message)})
    buffer_update = BufferUpdate.new(:buffer_id => response.parsed_response["updates"][0]["id"])
    message.buffer_update = buffer_update
    message.save
  end
end