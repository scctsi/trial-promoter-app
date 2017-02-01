class ImagePolicy < ApplicationPolicy
  def import?
    user.role.administrator?
  end
  
  def tag_images?
    user.role.administrator?
  end
end