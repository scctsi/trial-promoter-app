class ExperimentPolicy < ApplicationPolicy
  def create_messages?
    user.role.administrator?
  end

  def create_analytics_file_todos?
    user.role.administrator?
  end
  
  def set_experiment?
    user.role.administrator?
  end

  def parameterized_slug?
    user.role.administrator?
  end
end