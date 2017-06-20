class CampaignMatcher

  def self.match_campaign_id(messages, campaigns)
    campaigns.each do |campaign|
      campaign.name = clean_ad_name(campaign.name)

      messages.each do |message|
        next if !message.matchable? || !date_match?(message, campaign.start_date) || instagram?(message)
        message.campaign_id = campaign.id if message.content.include?(campaign.name)
      end
    end
    messages.each do |message|
      set_unmatchable(message)
      message.save
    end
  end
end

def clean_ad_name(campaign_name)
  campaign_name.gsub!("...", "")
  campaign_name.gsub!("Post: ", "")
  campaign_name.gsub!('"', "")
end

def date_match?(message, campaign_start_date)
  message.scheduled_date_time == Date.parse(campaign_start_date).to_s
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