class AnalyticsFilePolicy < ApplicationPolicy
  def update?
    user.role.administrator?
  end
end