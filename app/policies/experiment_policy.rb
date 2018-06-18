class ExperimentPolicy < ApplicationPolicy
  def index?
    user.role.administrator? || record.users.include?(user)
  end

  def new?
    user.role.administrator?
  end

  def show?
    user.role.administrator? || record.users.include?(user)
  end
  
  def create?
    user.role.administrator? 
  end

  def update?
    user.role.administrator?
  end

  def edit?
    update?
  end
  
  def send_to_buffer?
    user.role.administrator?
  end

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

  def correctness_analysis?
    user.role.administrator?
  end

  def messages_page?
    user.role.administrator? || record.users.include?(user)
  end
  
  def comments_page?
    user.role.administrator? || record.users.include?(user)
  end
end