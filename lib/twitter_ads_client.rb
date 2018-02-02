class TwitterAdsClient
  def initialize
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    Setting[:twitter]=secrets['twitter']
    @client = TwitterAds::Client.new( 
      Setting[:twitter]["consumer_key"],
      Setting[:twitter]["consumer_secret"],
      Setting[:twitter]["access_token"],
      Setting[:twitter]["access_token_secret"],
      
      #TODO put sandbox option
    )
  end
    
  def get_account
    @client.accounts
  end
  
  def get_campaigns(ad_account_id)
    account = get_account(ad_account_id)
    account.campaigns
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
