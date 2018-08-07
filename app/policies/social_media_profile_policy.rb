class SocialMediaProfilePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.role.administrator?
        scope.all
      end
    end
  end
  
  def edit?
    user.role.administrator?
  end
  
  def update?
    user.role.administrator?
  end
  
  def sync_with_buffer?
    user.role.administrator?
  end
  
  def index?
    user.role.administrator?
  end
end