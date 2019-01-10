class DataDictionaryPolicy < ApplicationPolicy
  def edit?
    user.role.administrator? || record.experiment.users.include?(user)
  end
  
  def update?
    user.role.administrator? || record.experiment.users.include?(user)
  end
  
  def show?
    user.role.administrator? || record.experiment.users.include?(user)
  end
end