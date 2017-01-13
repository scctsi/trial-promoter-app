class ExperimentPolicy < ApplicationPolicy
  def show?
    false
  end

  def create_messages?
    false
  end

  def set_experiment?
    false
  end
end