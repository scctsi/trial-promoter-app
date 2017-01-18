class CampaignPolicy < ApplicationPolicy
  def set_campaign?
    user.role.administrator?
  end
end

