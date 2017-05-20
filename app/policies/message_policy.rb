class MessagePolicy < ApplicationPolicy
  def edit_campaign_id?
    user.role.administrator?
  end
end