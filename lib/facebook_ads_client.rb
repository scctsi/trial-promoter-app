class FacebookAdsClient  
  def initialize
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    Setting[:facebook_access_token] = secrets['facebook_access_token']
    # Setting[:facebook_app_secret] = secrets['facebook_app_secret']
    @session = FacebookAds::Session.new(access_token: Setting[:facebook_access_token])
  end
  
  def get_account(account)
    @account = FacebookAds::AdAccount.get(account, @session) 
    return @account
  end
end