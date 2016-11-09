class MessageGenerationParameterSetsController < ApplicationController
  before_action :set_experiment, only: [:new]
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
    params[:message_generation_parameter_set].permit(:promoted_websites_tag, 
                                                      :promoted_clinical_trials_tag, 
                                                      :promoted_properties_cycle_type, 
                                                      :selected_message_templates_tag, 
                                                      :selected_message_templates_cycle_type,
                                                      :medium_cycle_type,
                                                      :social_network_cycle_type,
                                                      :image_present_cycle_type,
                                                      :period_in_days,
                                                      :number_of_messages_per_social_network,
                                                      :experiment_id)
  end
end