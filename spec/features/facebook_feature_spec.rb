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

   it 'gets the token after clicking on link' do
     visit '/'
     click_link "Facebook"

     expect(@experiment.settings(:facebook).value).to include("client_access_token" => "mock_token")
   end
   
   it 'destroys the token after clicking on log out link' do
     visit '/'
     click_link "Facebook"
     
     click_link "Log out"
     expect(@experiment.settings(:facebook).value).not_to include("client_access_token" => "mock_token")
   end
 end
end