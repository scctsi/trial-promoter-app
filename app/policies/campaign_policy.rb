class CampaignPolicy < ApplicationPolicy
  def show?
    false
  end

  def create_messages?
    false
  end

  def set_campaign?
    false
  end
end