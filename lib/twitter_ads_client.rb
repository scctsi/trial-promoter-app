class TwitterAdsClient
  def initialize(sandbox = false)
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    Setting[:twitter] = secrets['twitter']
    
    @client = TwitterAds::Client.new(
      Setting[:twitter]["consumer_key"],
      Setting[:twitter]["consumer_secret"],
      Setting[:twitter]["access_token"],
      Setting[:twitter]["access_token_secret"],
      sandbox: sandbox
    )
  end
    
  def get_account
    return @client.accounts
  end
  
  def get_campaigns(ad_account_id)
    return @client.accounts(ad_account_id).campaigns
  end
  
  def get_campaign(ad_account_id, campaign_id)
    return @client.accounts(ad_account_id).campaigns(campaign_id)
  end
  
  def get_line_item(ad_account_id, line_item_id)
    return @client.accounts(ad_account_id).line_items(line_item_id)
  end
  
  def get_targeting_criteria(ad_account_id, line_item_id, targeting_criteria_id)
    return @client.accounts(ad_account_id).line_items(line_item_id).targeting_criteria(targeting_criteria_id)
  end

  def create_campaign(account, campaign_params = {})
    campaign = TwitterAds::Campaign.new(account)
    campaign.funding_instrument_id = account.funding_instruments.first.id
    campaign.total_budget_amount_local_micro = campaign_params[:total_budget_amount_local_micro]
    campaign.daily_budget_amount_local_micro = campaign_params[:daily_budget_amount_local_micro]
    campaign.name = campaign_params[:name]
    campaign.entity_status = campaign_params[:entity_status]
    
    campaign.start_time = campaign_params[:start_time]
    campaign.save
    
    return campaign
  end
  
  def create_line_item(ad_account, campaign_id, line_item_params = {})
    line_item = TwitterAds::LineItem.new(ad_account)
    line_item.campaign_id = campaign_id
    line_item.name = line_item_params[:name]
    line_item.product_type = line_item_params[:product_type]
    line_item.placements = line_item_params[:placements]
    line_item.objective = line_item_params[:objective]
    line_item.bid_type = line_item_params[:bid_type]
    line_item.entity_status = line_item_params[:entity_status]
    line_item.save
  end

  def create_targeting_criteria(ad_account, line_item, targeting_criteria_params = {})
    targeting_criteria = TwitterAds::TargetingCriteria.new(ad_account)
    targeting_criteria.line_item_id = line_item.id
    targeting_criteria.targeting_type = targeting_criteria_params[:targeting_type]
    targeting_criteria.location_type = targeting_criteria_params[:location_type]
    targeting_criteria.targeting_value = targeting_criteria_params[:targeting_value]
    targeting_criteria.save
  end
  
  def pause_campaign(campaign)
    campaign.entity_status = 'PAUSED'
    campaign.save
  end
  
  def delete_campaign(campaign)
    campaign.delete!
  end

  def get_scoped_timeline(ad_account_id, campaign_id)
    @client.accounts(ad_account_id).scoped_timeline(campaign_id)
  end
  
  def promote_tweet(account, line_item_id, tweet_id)
    promoted_tweet = TwitterAds::Creative::PromotedTweet.new(account)
    promoted_tweet.line_item_id = line_item_id
    promoted_tweet.tweet_id = tweet_id
    promoted_tweet.save
  end
end
