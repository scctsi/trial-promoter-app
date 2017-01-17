class SocialMediaProfilesController < ApplicationController
  def sync_with_buffer
    BufferClient.get_social_media_profiles
    redirect_to admin_settings_url
  end
end
