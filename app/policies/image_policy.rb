class ImagePolicy < ApplicationPolicy
  def add?
    user.role.administrator?
  end

  def import?
    user.role.administrator?
  end
  
  def check_validity_for_instagram_ads?
    user.role.administrator?
  end
end