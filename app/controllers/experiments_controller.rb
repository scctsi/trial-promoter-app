class ExperimentsController < ApplicationController
  before_action :set_experiment, only: [:show, :edit, :update, :parameterized_slug, :create_messages, :create_analytics_file_todos]
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
    @messages = Message.where(:message_generating_id => @experiment.id).page(params[:page]).order('created_at ASC')
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
    respond_to do |format|
      @experiment.create_messages
      format.html { redirect_to experiment_url(@experiment) }
      format.json { render json: { success: true } }
    end 
  end

  def create_analytics_file_todos
    @experiment.create_analytics_file_todos
    redirect_to experiment_url(@experiment)
  end

  def calculate_message_count
    authorize Experiment
    message_count = MessageGenerationParameterSet.calculate_message_count(params[:social_network_choices_count].to_i, params[:medium_choices_count].to_i, params[:period_in_days].to_i, params[:number_of_messages_per_social_network].to_i)
    render json: { message_count: message_count }
  end

  private

  def set_experiment
    @experiment = Experiment.find(params[:id])
    authorize @experiment
  end

  def experiment_params
    # TODO: Unit test this
    params.require(:experiment).permit(:name, :start_date, :end_date, :message_distribution_start_date, {:social_media_profile_ids => []}, message_generation_parameter_set_attributes: [:social_network_distribution, :medium_distribution, :image_present_distribution, :period_in_days, :number_of_messages_per_social_network, social_network_choices: [], medium_choices: [], image_present_choices: []])
  end
end