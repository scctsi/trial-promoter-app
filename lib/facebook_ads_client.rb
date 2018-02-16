class FacebookAdsClient  
  def initialize(account_id)
    secrets = YAML.load_file("#{Rails.root}/spec/secrets/secrets.yml")
    Setting[:facebook_ads_access_token] = secrets['facebook_ads_access_token']
    Setting[:facebook_app_secret] = secrets['facebook_app_secret']
    FacebookAds.configure do |config|
      config.access_token = Setting[:facebook_ads_access_token]
      config.app_secret = Setting[:facebook_app_secret]
    end
    @account_id = account_id
  end
  
  def get_account
    @ad_account = FacebookAds::AdAccount.get(@account_id)
    return @ad_account
  end
    
  def get_account_name(account)
    return account.name
  end
  
  def get_campaign_names
    return @ad_account.campaigns(fields: 'name').map(&:name)
  end
  
  # REF ad-campaign-group for kpi_type (tracks link clicks on ads) https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group
  def create_campaign(campaign_params)
    @ad_account.campaigns.create({
      name: campaign_params[:name],
      objective: campaign_params[:objective],
      status: campaign_params[:status],
      # kpi_type: campaign_params[:kpi_type]
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
  
  def update_ad_set(ad_set_id)
    
  end

  # REF https://developers.facebook.com/docs/marketing-api/reference/ad-campaign
  # targeting https://developers.facebook.com/docs/marketing-api/targeting-specs
  def create_ad_set(ad_set)
    @ad_account.adsets.create({
      name: ad_set[:name],
      campaign_id: ad_set[:campaign_id],
      billing_event: ad_set[:billing_event],
      targeting: ad_set[:targeting],
      bid_amount: ad_set[:bid_amount],
      daily_budget: ad_set[:daily_budget],
      lifetime_budget: ad_set[:lifetime_budget],
      pacing_type: ad_set[:pacing_type],
      end_time: ad_set[:end_time],
      adset_schedule: ad_set[:adset_schedule],
      promoted_object: ad_set[:promoted_object],
      optimization_goal: ad_set[:optimization_goal],
      status: ad_set[:status]
    })
  end
  
  def create_ad_set_from_message(message)
    ad_set_template = {
      name: "Eat More Fat",
      campaign_id: "120330000026550903",
      billing_event: "IMPRESSIONS", 
      targeting: {
          geo_locations: {
            countries: ['US']
          }
        },
      bid_amount: 3000,
      daily_budget: nil,
      lifetime_budget: 100000,
      pacing_type: ['day_parting'],
      end_time: message.end_time,
      adset_schedule: [{
            start_minute: message.setup_start_minute,
            end_minute: message.setup_end_minute,
            days: [0, 1, 2, 3, 4, 5, 6],
          }],
      promoted_object: { application_id: '135216893922228' },
      optimization_goal: 'IMPRESSIONS',
      status: 'ACTIVE'
    }
    
    return create_ad_set(ad_set_template)
  end
  
  def create_adcreative_from_message(message)
    name = "Stress Less!"
    object_story_spec = {
      page_id: "641520102717189",
      template_data: {
        additional_image_index: 0,
        call_to_action: { type: 'LEARN_MORE' },
        description: "Live Longer",
        message: message.content,
        link: message.tracking_url,
        name: "Treat Yoself!"
      }
    }
    
    return create_adcreative(name, object_story_spec)
  end
  
  def create_adcreative(ad_name, object_story_spec)
    @ad_account.adcreatives.create({
      name: ad_name,
      object_story_spec: object_story_spec
    })
  end
  
  def create_ad(object_story_spec)
    @ad_account.ads.create(object_story_spec)
  end
    
  def create_ad_from_message
    object_story_spec = {
      creative: { creative_id: 120330000026551103 },
      adset_id: "120330000026551503",
      name: "Dat Ad",
      status: 'ACTIVE'
    }
    return @ad_account.ads.create(object_story_spec)
  end
  
  def create_ad_pixel(account_id, name)
    @ad_account.adspixels.create(parent_id: account_id, name: name)
  end
  
  def delete_campaign(campaign_id)
    campaign = FacebookAds::Campaign.get(campaign_id)
    campaign.destroy
  end
end  