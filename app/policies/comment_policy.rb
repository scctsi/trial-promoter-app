class CommentPolicy < ApplicationPolicy
  def edit_codes?
    user.role.administrator?
  end
end