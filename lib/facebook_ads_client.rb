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
  
  def get_campaign_names
    return @account.campaigns(fields: 'name, comments').map(&:name)
  end  
  
  def get_all_campaign_ids
    return @account.campaigns(fields: 'id').map(&:id)
  end
  
  def get_ads(campaign_id)
    return @account.get(campaign_id: campaign_id, fields: 'ads')
  end
  
  def get_comments(object_id)
    @account.reload!
    # return @account.get(field: 'me', 'comments')
    campaign = @account.get(object_id)
    return campaign
  end
end