class FacebookClient
  def initialize
    Zuck.graph = Koala::Facebook::API.new(Setting[:facebook_access_token])
  end
  
  def get_accounts
    return Zuck::AdAccount.all
  end
  
  def get_campaigns(account)
    account.campaigns
  end
  
  def campaign_exists?(account, name)
    campaign_exists = false
    
    campaigns = get_campaigns(account)
    campaigns.each do |campaign|
      campaign_exists = true if campaign.name == name
    end
    
    campaign_exists
  end
  
  # REF: https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group
  def create_campaign(account, name)
    account.create_campaign({ name: name, objective: 'LINK_CLICKS' }) if !campaign_exists?(account, name)
  end
end