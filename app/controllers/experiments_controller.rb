class ExperimentsController < ApplicationController
  before_action :set_experiment, only: [:show, :edit, :update, :parameterized_slug, :send_to_buffer, :create_messages, :correctness_analysis, :messages_page, :comments_page
  ]
  before_action :set_click_meter_groups_and_domains, only: [:new, :edit]
  layout "workspace", only: [:show, :correctness_analysis]

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
    @messages = Message.where(:message_generating_id => @experiment.id).page(params[:page]).order('scheduled_date_time ASC')
    @top_messages_by_click_rate = Message.where('message_generating_id = ? AND click_rate is not null', @experiment.id).order('click_rate desc')
    @top_messages_by_website_goal_rate = Message.where('message_generating_id = ? AND website_goal_rate is not null', @experiment.id).order('website_goal_rate desc, website_session_count desc')

    @comments = Comment.joins(:message).page(params[:page]).per(20).order('toxicity_score DESC')

    respond_to do |format|
      format.html
      format.json { render :layout => false }
    end
  end

  def correctness_analysis
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
      DataDictionary.create_data_dictionary(@experiment)
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

  def send_to_buffer
    PublishMessagesJob.perform_later
    flash[:notice] = 'Messages scheduled for the next 7 days have been pushed to Buffer'
    redirect_to experiment_url(@experiment)
  end

  def create_messages
    respond_to do |format|
      GenerateMessagesJob.perform_later(@experiment)
      format.html { redirect_to experiment_url(@experiment) }
      format.json { render json: { success: true } }
    end
  end

  def messages_page
    messages = Message.where(:message_generating_id => @experiment.id).page(params[:page]).order('scheduled_date_time ASC')

    respond_to do |format|
      format.json
      format.html { render :partial => 'shared/messages_page', locals: { messages: messages } }
    end
  end
  
  def comments_page
    comments = Comment.joins(:message).page(params[:page]).per(100).order('toxicity_score DESC')

    respond_to do |format|
      format.json
      format.html { render :partial => 'shared/comments_page', locals: { comments: comments } }
    end
  end

  private

  def set_experiment
    @experiment = Experiment.find(params[:id])
    authorize @experiment
  end

  def set_click_meter_groups_and_domains
    @click_meter_groups = ClickMeterClient.get_groups(@experiment)
    @click_meter_domains = ClickMeterClient.get_domains(@experiment)
  end

  def experiment_params
    # TODO: Unit test this
    params.require(:experiment).permit(:name, :message_distribution_start_date, :click_meter_group_id, :click_meter_domain_id, :twitter_posting_times, :facebook_posting_times, :instagram_posting_times, {:social_media_profile_ids => []}, message_generation_parameter_set_attributes: [:number_of_cycles, :number_of_messages_per_social_network, :image_present_choices, social_network_choices: [], medium_choices: []])
  end
end