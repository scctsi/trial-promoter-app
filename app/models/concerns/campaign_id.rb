module CampaignId
  extend ActiveSupport::Concern

  def show_campaign_id?
    self.platform != :twitter && self.medium == :ad && exists
  end

  def edit_campaign_id?
    !exists && self.platform != :twitter && self.medium == :ad
  end

  def exists
    !self.campaign_id.nil?
  end
end