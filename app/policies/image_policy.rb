class ImagePolicy < ApplicationPolicy
  def import?
    user.role.administrator?
  end
end