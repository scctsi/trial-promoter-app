class ClinicalTrialsController < ApplicationController
  def index
    @clinical_trials = ClinicalTrial.all
  end
  
  def new
    @clinical_trial = ClinicalTrial.new
    @hashtags = Hashtag.all
  end
  
  def create
    @clinical_trial = ClinicalTrial.new(clinical_trial_params)

    if @clinical_trial.save
      redirect_to clinical_trials_url
    else
      render :new
    end
  end

private 
  def clinical_trial_params
    # TODO: Unit test this
    params[:clinical_trial].permit(:title, :pi_first_name, :pi_last_name, :url, :disease) 
  end
end

