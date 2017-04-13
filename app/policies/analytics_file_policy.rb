class AnalyticsFilePolicy < ApplicationPolicy
  def update?
    user.role.administrator?
  end
  
  def process_all_files?
    user.role.administrator?
  end
end