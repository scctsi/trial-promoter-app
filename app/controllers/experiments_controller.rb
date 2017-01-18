class ExperimentsController < ApplicationController
  before_action :set_experiment, only: [:show, :edit, :update, :parameterized_slug, :create_messages]
  layout "workspace", only: [:show]

  def index
    authorize Experiment
    @experiments = Experiment.all
  end

  def parameterized_slug
    render json: { parameterized_slug: @experiment.to_param }
  end

  def show
    authorize @experiment
    @message_templates = MessageTemplate.belonging_to(@experiment)
    @images = Image.belonging_to(@experiment)
    @websites = Website.belonging_to(@experiment)
    # TODO: Unit test this
    @selected_tab = params[:selected_tab] || 'setup'
    # @selected_tab = 'setup' if !@selected_tab
    @messages = Message.all
  end

  def new
    @experiment = Experiment.new
    authorize @experiment
    @experiment.build_message_generation_parameter_set
  end

  def create
    @experiment = Experiment.new(experiment_params)
    authorize @experiment
    # TODO: There should be an easier way to automatically set the parent object
    @experiment.message_generation_parameter_set.message_generating = @experiment if (!@experiment.message_generation_parameter_set.nil?)

    if @experiment.save
      redirect_to experiment_url(@experiment)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @experiment.update(experiment_params)
      redirect_to experiment_url(@experiment)
    else
      render :edit
    end
  end

  def create_messages
    @experiment.create_messages
    redirect_to experiment_url(@experiment)
  end

  private

  def set_experiment
    @experiment = Experiment.find(params[:id])
    authorize @experiment
  end

  def experiment_params
    # TODO: Unit test this
    params.require(:experiment).permit(:name, :start_date, :end_date, :message_distribution_start_date, message_generation_parameter_set_attributes: [:social_network_distribution, :medium_distribution, :image_present_distribution, :period_in_days, :number_of_messages_per_social_network, social_network_choices: [], medium_choices: [], image_present_choices: []])
    # params[:experiment].permit(:name, :start_date, :end_date, :message_distribution_start_date, {:clinical_trial_ids => []}, message_generation_parameter_set_attributes: [:id, :promoted_websites_tag, :promoted_clinical_trials_tag, :promoted_properties_cycle_type, :selected_message_templates_tag, :selected_message_templates_cycle_type, :medium_cycle_type, :social_network_cycle_type, :image_present_cycle_type, :period_in_days, :number_of_messages_per_social_network])
  end
end
