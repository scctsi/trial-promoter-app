require 'rails_helper'

describe "authorizing accounts", type: :request do
 context 'when authenticating with facebook' do
   before do
     sign_in create(:administrator)
     @experiment = create(:experiment)
     OmniAuth.config.test_mode = true
     OmniAuth.config.mock_auth[:facebook] = nil
     OmniAuth.config.mock_auth[:facebook] = {
       'provider' => 'facebook',
       'uid' => '123545',
       'user_info' => {
         'name' => 'mockuser',
         'image' => 'mock_user_thumbnail_url'
       },
       'credentials' => {
         'token' => 'mock_token',
         'secret' => 'mock_secret'
       }
     }
     Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
     Rails.application.env_config["omniauth.params"] = { experiment_id: @experiment.id.to_s }
   end

   it 'does stuff' do
     visit '/'
     click_link "Facebook"



   # mock_auth_hash
   # click_link "Sign in"
   end
 end
end