class ExperimentPolicy < ApplicationPolicy
  def send_to_buffer?
    user.role.administrator?
  end

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

  def calculate_message_count?
    user.role.administrator?
  end
end