require 'rails_helper'

RSpec.describe FacebookSessionsController, type: :controller do
  before do 
    sign_in create(:administrator)
    OmniAuth.config.add_mock(:facebook, { :uid => '12345' })
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook] 
  end
  
  describe '#create' do
  end
end