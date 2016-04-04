class ClinicalTrialsController < ApplicationController
  def index
    @all_trials = ClinicalTrial.all.order(:nct_id)
    @selected_trials = ClinicalTrial.where(:randomization_status => 'Selected')
    @control_trials = ClinicalTrial.where(:randomization_status => 'Control')
    @unused_trials = ClinicalTrial.where(:randomization_status => 'Unused')
  end
end
