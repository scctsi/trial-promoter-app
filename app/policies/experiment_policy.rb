class ExperimentPolicy < ApplicationPolicy
  def create_messages?
    user.role.administrator?
  end

  def set_experiment?
    user.role.administrator?
  end

  def parameterized_slug?
    user.role.administrator?
  end

  def calculate_message_count?
    user.role.administrator?
  end
end