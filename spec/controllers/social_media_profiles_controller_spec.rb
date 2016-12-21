require 'rails_helper'

RSpec.describe SocialMediaProfilesController, type: :controller do

  describe "GET #sync_with_buffer" do
    before do
      allow(Buffer).to receive(:get_social_media_profiles)
      get :sync_with_buffer
    end

    it 'calls the Buffer library to sync up the social media profiles' do
      expect(Buffer).to have_received(:get_social_media_profiles)
    end
    
    it 'redirects to the Settings index page' do
      expect(response).to redirect_to admin_settings_url
    end
  end
end
