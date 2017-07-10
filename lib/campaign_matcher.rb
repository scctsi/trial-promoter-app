class CampaignMatcher
  def self.match_campaign_id(messages, campaigns)
    campaign_name_repeats = campaigns.group_by{|campaign| campaign.name}.select{|key,value| key if value.count > 1 }
    campaign_name_rejects = []

    campaign_name_repeats.each do |key, _value|
      campaign_name_rejects << campaigns.select{|campaign| campaign.name.include?(key)}
      campaigns.reject!{|campaign| campaign.name.include?(key)}
    end

    campaigns.each do |campaign|
      campaign.name = clean_ad_name(campaign.name)
      messages.each do |message|
        next if !message.matchable? || instagram?(message)
        message.campaign_id = campaign.id if message.content.include?(campaign.name)
      end
    end

    messages.each do |message|
      set_unmatchable(message)
      message.save
    end
    return campaign_name_rejects
  end
end

def clean_ad_name(campaign_name)
  campaign_name.gsub!("...", "")
  campaign_name.gsub!("Post: ", "")
  campaign_name.delete!('"')
end

def set_unmatchable(message)
  message.campaign_unmatchable = true if message.campaign_id == nil
end

def instagram?(message)
  if message.platform == :instagram
    set_unmatchable(message)
    return true
  else
    return false
  end
end