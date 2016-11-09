class ExperimentsController < ApplicationController
  before_action :set_experiment, only: [:show, :edit, :update]
  layout "workspace", only: [:show]
  
  def index
    @experiments = Experiment.all
  end

  def new
    @experiment = Experiment.new
  end
  
  def edit
  end

  def create
    @experiment = Experiment.new(experiment_params)

    if @experiment.save
      redirect_to experiments_url
    else
      render :new
    end
  end

  def update
    if @experiment.update(experiment_params)
      redirect_to experiments_url
    else
      render :edit
    end
  end
  
  private
  
  def set_experiment
    @experiment = Experiment.find(params[:id])
  end

  def experiment_params
    # TODO: Unit test this
    params[:experiment].permit(:name, :start_date, :end_date, :message_distribution_start_date, {:clinical_trial_ids => []}, message_generation_parameter_set_attributes: [:id, :promoted_websites_tag, :promoted_clinical_trials_tag, :promoted_properties_cycle_type, :selected_message_templates_tag, :selected_message_templates_cycle_type, :medium_cycle_type, :social_network_cycle_type, :image_present_cycle_type, :period_in_days, :number_of_messages_per_social_network])
  end
end
