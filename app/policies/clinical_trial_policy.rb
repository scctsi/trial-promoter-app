class ClinicalTrialPolicy < ApplicationPolicy
  def show?
    false
  end

  def create_messages?
    false
  end

  def set_campaign?
    false
  end

  def set_clinical_trial?
    false
  end
end