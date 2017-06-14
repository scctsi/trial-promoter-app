module CampaignId
  extend ActiveSupport::Concern

  def show_campaign_id?
    # Only facebook and instagram ads need manual entry of campaign IDs
    self.platform != :twitter && self.medium == :ad && !self.campaign_id.blank?
  end

  def edit_campaign_id?
    self.campaign_id.blank? && self.platform != :twitter && self.medium == :ad
  end
end