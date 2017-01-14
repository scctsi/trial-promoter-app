require 'rails_helper'

RSpec.describe SocialMediaProfilesController, type: :controller do

  describe "GET #sync_with_buffer" do
    before do
      sign_in create(:administrator)
      allow(Buffer).to receive(:get_social_media_profiles)
      get :sync_with_buffer
    end

    it 'calls the Buffer library to sync up the social media profiles' do
      expect(Buffer).to have_received(:get_social_media_profiles)
    end

    it 'redirects to the Settings index page' do
      expect(response).to redirect_to admin_settings_url
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :sync_with_buffer

      expect(response).to redirect_to :new_user_session
    end
  end
end
