require 'rails_helper'

RSpec.describe SocialMediaProfilesController, type: :controller do
  before do
    sign_in create(:administrator)
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    @experiment = build(:experiment)
    @experiment.set_api_key('buffer', secrets["buffer_access_token"])
  end
  
  describe "GET #sync_with_buffer (development only tests)", :development_only_tests => true do 
    before do
      allow(BufferClient).to receive(:get_social_media_profiles)
      get :sync_with_buffer, experiment: @experiment
    end

    it 'calls the Buffer library to sync up the social media profiles' do
      expect(BufferClient).to have_received(:get_social_media_profiles)
    end

    it 'redirects to the social media profiles index page' do
      expect(response).to redirect_to social_media_profiles_url
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :sync_with_buffer

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'GET #index' do
    let(:social_media_profiles) { build_pair(:social_media_profile) }

    before do
      allow(SocialMediaProfile).to receive(:all).and_return(social_media_profiles)
      get :index
    end

    it 'assigns all existing social media profiles to @social_media_profiles' do
      expect(assigns(:social_media_profiles)).to eq(social_media_profiles)
    end

    it { is_expected.to respond_with :ok }
    it { is_expected.to render_template :index }

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :index

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'GET #edit' do
    before do
      @social_media_profile = create(:social_media_profile)
      get :edit, id: @social_media_profile
    end

    it 'assigns the requested social media profile to @social_media_profile' do
      expect(assigns(:social_media_profile)).to eq(@social_media_profile)
    end

    it 'renders the edit template' do
      expect(response).to render_template :edit
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :edit, id: @social_media_profile

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'PATCH update' do
    before :each do
      @social_media_profile = create(:social_media_profile)
      patch :update, id: @social_media_profile, social_media_profile: attributes_for(:social_media_profile, allowed_mediums: ['ad', 'organic'])
    end

    context 'with valid attributes' do
      it 'locates the requested social media profile' do
        expect(assigns(:social_media_profile)).to eq(@social_media_profile)
      end

      it "changes the social media profile's attributes" do
        @social_media_profile.reload
        expect(@social_media_profile.allowed_mediums).to eq([:ad, :organic])
      end

      it 'redirects to the index page' do
        expect(response).to redirect_to social_media_profiles_url
      end
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      patch :update, id: @social_media_profile

      expect(response).to redirect_to :new_user_session
    end
  end
end
