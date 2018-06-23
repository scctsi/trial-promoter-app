class DataDictionaryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.role.administrator?
        scope.all
      else
        User.find(user.id).experiments
      end
    end
  end
  
  def edit?
    user.role.administrator? || record.users.include?(user)
  end
  
  def update?
    user.role.administrator? || record.users.include?(user)
  end
  
  def show?
    user.role.administrator? || record.users.include?(user)
  end
end