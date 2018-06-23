class AnalyticsFilePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.role.administrator?
        scope.all
      end
    end
  end
  
  def update?
    user.role.administrator?
  end
  
  def process_all_files?
    user.role.administrator?
  end
end