class SocialMediaProfilePolicy < ApplicationPolicy
  def sync_with_buffer?
    user.role.administrator?
  end
  
  def index?
    user.role.administrator?
  end
end