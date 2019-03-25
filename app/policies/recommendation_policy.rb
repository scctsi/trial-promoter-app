class RecommendationPolicy < ApplicationPolicy
  def get?
    user.role.administrator?
  end
end