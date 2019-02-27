class ListeningPolicy < ApplicationPolicy
  def index?
    user.role.administrator?
  end
end