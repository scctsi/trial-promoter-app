class ImagePolicy < ApplicationPolicy
  def import?
    user.role.administrator?
  end
  
  def check_validity_for_instagram_ads?
    user.role.administrator?
  end
end