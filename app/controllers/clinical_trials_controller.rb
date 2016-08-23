class ClinicalTrialsController < ApplicationController
  def index
    @clinical_trials = ClinicalTrial.all
  end
  
  def new
    @clinical_trial = ClinicalTrial.new
  end
  
  def create
    ClinicalTrial.create!(clinical_trial_params)
    redirect_to clinical_trials_url
  end

private 
  def clinical_trial_params
    # TODO: Unit test this
    params[:clinical_trial].permit(:title, :pi_first_name, :pi_last_name, :url, :disease) 
  end
end

