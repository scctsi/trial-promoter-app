class MessagePolicy < ApplicationPolicy
  def edit_campaign_id?
    user.role.administrator?
  end

  def new_campaign_id?
    user.role.administrator?
  end
  
  def edit_note?
    user.role.administrator?
  end
  
  def new_note?
    user.role.administrator?
  end
end