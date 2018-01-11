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

  def get_paginated_ads(ad_id)
    return @graph.get_connections(ad_id, 'ads')
  end
  
  def get_all_campaign_ids
    return @account.campaigns(fields: 'id').map(&:id)
  end
  
  def get_ad_sets
    campaigns = @account.campaigns
    @ad_sets = []
    campaigns.each do |campaign|
      @ad_sets << campaign.adsets
    end
    return @ad_sets
  end
     
  def get_ads
    ad_sets = @account.adsets
    @ads = []
    ad_sets.each do |ad_set|
      @ads << ad_set.ads
    end
    return @ads
  end
  
  def get_comments(object_id)
    @account.reload!
    
    # return @account.get(field: 'me', 'comments')
    campaign = @account.get(object_id: object_id)
    # p campaign
    return campaign
  end
  
  def get_paginated_ads
    return @graph.get_connections(ad_account: @account_id, fields: 'ads')
  end
end