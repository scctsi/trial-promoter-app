class ClinicalTrialsController < ApplicationController
  before_action :set_clinical_trial, only: [:edit, :update]

  def index
    authorize ClinicalTrial
    @clinical_trials = ClinicalTrial.all
  end

  def new
    @clinical_trial = ClinicalTrial.new
    authorize @clinical_trial
    @hashtags = Hashtag.all
  end

  def edit
    @hashtags = Hashtag.all
    authorize @clinical_trial
  end

  def create
    @clinical_trial = ClinicalTrial.new(clinical_trial_params)
    authorize @clinical_trial
    if @clinical_trial.save
      redirect_to clinical_trials_url
    else
      render :new
    end
  end

  def update
    authorize @clinical_trial
    if @clinical_trial.update(clinical_trial_params)
      redirect_to clinical_trials_url
    else
      render :edit
    end
  end

  private

  def set_clinical_trial
    @clinical_trial = ClinicalTrial.find(params[:id])
  end

  def clinical_trial_params
    # TODO: Unit test this
    params[:clinical_trial].permit(:title, :pi_first_name, :pi_last_name, :url, :disease, :hashtags)
  end
end

