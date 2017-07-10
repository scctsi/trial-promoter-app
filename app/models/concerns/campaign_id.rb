module CampaignId
  extend ActiveSupport::Concern

  def showable?
    # Only facebook and instagram ads need manual entry of campaign IDs
    self.platform != :twitter && self.medium == :ad && !self.campaign_id.blank?
  end

  def editable?
    self.campaign_id.blank? && self.platform != :twitter && self.medium == :ad
  end

  def matchable?
    self.campaign_id.blank? && self.publish_status == 'published_to_social_network'
  end
end