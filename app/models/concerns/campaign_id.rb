module CampaignId
  extend ActiveSupport::Concern

  def show_campaign_id?
    self.platform != :twitter && self.medium == :ad && campaign_id_exists?
  end

  def campaign_id_editable?
    !campaign_id_exists? && self.platform != :twitter && self.medium == :ad
  end

  def campaign_id_exists?
    !self.campaign_id.nil?
  end
end