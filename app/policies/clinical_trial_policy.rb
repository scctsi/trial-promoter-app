class ClinicalTrialPolicy < ApplicationPolicy
  def set_clinical_trial?
    user.role.administrator?
  end
end