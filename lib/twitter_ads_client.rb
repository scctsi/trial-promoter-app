class TwitterAdsClient
  require 'oauth2'
  API_VERSION = '3.0'
  
  def initialize(sandbox = false)
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    Setting[:twitter] = secrets['twitter']
    
    @twitter_ads_client = TwitterAds::Client.new(
      Setting[:twitter]["consumer_key"],
      Setting[:twitter]["consumer_secret"],
      Setting[:twitter]["access_token"],
      Setting[:twitter]["access_token_secret"],
      sandbox: sandbox
    )
    
    # @client = OAuth2::Client.new( 
    #   '@BeFreeOfTobacco',
    #   Setting[:twitter]["consumer_key"],
    #   # Setting[:twitter]["consumer_secret"],
    #   site: 'https://ads-api-sandbox.twitter.com/3/accounts?account_ids=gq1axo'
    #   # Setting[:twitter]["access_token"],
    #   # Setting[:twitter]["access_token_secret"],
    #   # sandbox: sandbox 
    # )
  end
    
  def get_account
    @twitter_ads_client.accounts('gq1axo')
    # @client.auth_code.authorize_url(:redirect_uri => 'http://0.0.0.0:3000/oauth2/callback')
    # p @client.auth_code
    # token = @client.auth_code.get_token('authorization_code', :redirect_uri => 'http://0.0.0.0:3000/oauth2/callback', :headers => {'Authorization' => 'Basic some_password'})

  end
  
  def get_campaigns(ad_account_id)
    account = get_account
    resource = "/TwitterAds::3.0/accounts/#{account.first.id}/features"
    
    account.first.campaigns
  end

  def create_campaign
    account = @client.create_list(
      "params":{
      "start_time":"2017-07-10",
      "name":"batch campaigns",
      "funding_instrument_id":"lygyi",
      "daily_budget_amount_local_micro":140000000,
      "entity_status":"PAUSED"
    })
  end
  
  def delete_campaign
  end
end
