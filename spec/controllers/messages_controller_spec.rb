require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  before do
    sign_in create(:administrator)
    @messages = create_list(:message, 2)
  end

  describe 'POST #edit_campaign_id' do
    before do
      post :edit_campaign_id, id: @messages[0].id, campaign_id: '123456'
    end

    it 'saves a campaign id to a message' do
      @messages[0].reload

      expect(@messages[0].campaign_id).to eq('123456')
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      post :edit_campaign_id, id: @messages[0].id, campaign_id: '123456'

      expect(response).to redirect_to :new_user_session
    end
  end

  describe 'GET #new_campaign_id' do
    before do
      get :new_campaign_id, id: @messages[0].id
    end

    it 'redirects unauthenticated user to sign-in page' do
      sign_out(:user)

      get :new_campaign_id, id: @messages[0].id

      expect(response).to redirect_to :new_user_session
    end
  end
end