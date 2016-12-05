class MessageGenerationParameterSetsController < ApplicationController
  before_action :set_experiment, only: [:new, :create]
  before_action :set_message_generation_paramter_set, only: [:edit, :update]
  
  def new
    @experiment.build_message_generation_parameter_set
  end

  def edit
  end

  def create
    @message_generation_parameter_set = @experiment.build_message_generation_parameter_set(message_generation_parameter_set_params)

    if @message_generation_parameter_set.save
      redirect_to experiment_url(@experiment)
    else
      render :new
    end
  end
  
  def update
    if @message_generation_parameter_set.update_attributes(message_generation_parameter_set_params)
      redirect_to experiment_url(@message_generation_parameter_set.message_generating)
    else
      render :edit
    end
  end

  private
  
  def set_experiment
    @experiment = Experiment.find(params[:experiment_id])
  end

  def set_message_generation_paramter_set
    @message_generation_parameter_set = MessageGenerationParameterSet.find(params[:id])
  end

  def message_generation_parameter_set_params
    # TODO: Unit test this
    params[:message_generation_parameter_set].permit( :social_network_distribution,
                                                      :medium_distribution,
                                                      :image_present_distribution,
                                                      :period_in_days,
                                                      :number_of_messages_per_social_network,
                                                      :experiment_id,
                                                      social_network_choices: [],
                                                      medium_choices: [],
                                                      image_choices: [])
  end
end