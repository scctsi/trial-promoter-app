class AdPolicy < ApplicationPolicy
  def previews?
    user.role.administrator?
  end

  def specifications?
    user.role.administrator?
  end
end
