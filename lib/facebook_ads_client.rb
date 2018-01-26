class FacebookAdsClient  
  def initialize
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    Setting[:facebook_ads_access_token] = secrets['facebook_ads_access_token']
    Setting[:facebook_app_secret] = secrets['facebook_app_secret']
    FacebookAds.configure do |config|
      config.access_token = Setting[:facebook_ads_access_token]
      config.app_secret = Setting[:facebook_app_secret]
    end
  end
  
  def get_account(account)
    @ad_account = FacebookAds::AdAccount.get(account)
    return @ad_account
  end
    
  def get_account_name(account)
    return account.name
  end
  
  
  
  def get_campaign_names
    return @ad_account.campaigns(fields: 'name').map(&:name)
  end
  
  # REF ad-campaign-group for kpi_type (tracks link clicks on ads) https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group
  def create_campaign(campaign_name, objective = 'CONVERSIONS', status = 'ACTIVE', kpi_type = 'LINK_CLICKS')
    @ad_account.campaigns.create({
      name: campaign_name,
      objective: objective,
      status: status,
      kpi_type: kpi_type
    })
  end
  
  def get_campaign_ids
    return @ad_account.campaigns(fields: 'id').map(&:id)
  end

  def get_ad_sets
    campaigns = @ad_account.campaigns
    @ad_sets = []
    campaigns.each do |campaign|
      @ad_sets << campaign.adsets
    end
    return @ad_sets
  end

  # REF https://developers.facebook.com/docs/marketing-api/reference/ad-campaign
  # targeting https://developers.facebook.com/docs/marketing-api/targeting-specs
  def create_ad_set(ad_set_name, campaign_id, billing_event = "IMPRESSIONS",  status = "PAUSED", targeting, bid_amount, daily_budget, promoted_object, optimization_goal)
    @ad_account.adsets.create({
      name: ad_set_name,
      campaign_id: campaign_id,
      billing_event: billing_event,
      targeting: targeting,
      bid_amount: bid_amount,
      daily_budget: daily_budget,
      promoted_object: promoted_object,
      optimization_goal: optimization_goal,
      status: status
    })
  end
  
  def create_adcreative(ad_name, object_story_spec)
    @ad_account.adcreatives.create({
      name: ad_name,
      object_story_spec: object_story_spec
    })
  end
  
  def create_ad(object_story_spec)
    @ad_account.ads.create([
      MultiJson.dump(object_story_spec)
    ])
  end
  
  def create_ad_pixel(account_id, name)
    @ad_account.adspixels.create(parent_id: account_id, name: name)
  end
  
  def get_ad_pixel(account_id, name)
    @ad_account.adspixels(parent_id: account_id, name: name)
  end
  
  # def get_ads
  #   ad_sets = @ad_account.adsets
  #   @ads = []
  #   ad_sets.each do |ad_set|
  #     @ads << ad_set.ads
  #   end
  #   return @ads
  # end
  
  # def get_comments(object_id)
  #   @ad_account.reload!
    
  #   # return @ad_account.get(field: 'me', 'comments')
  #   campaign = @ad_account.get(object_id: object_id)
  #   # p campaign
  #   return campaign
  # end
  
  def delete_campaign(campaign_id)
    campaign = FacebookAds::Campaign.get(campaign_id)
    campaign.destroy
  end
end  