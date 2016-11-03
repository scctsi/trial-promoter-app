class MessageGenerationParameterSetsController < ApplicationController
  def new
    @message_generation_parameter_set = MessageGenerationParameterSet.new
  end

  # def edit
  # end

  # def create
  #   @message_generation_parameter_set = Experiment.new(experiment_params)

  #   if @experiment.save
  #     redirect_to experiments_url
  #   else
  #     render :new
  #   end
  # end
end

# class ExperimentsController < ApplicationController
#   before_action :set_experiment, only: [:show, :edit, :update]
#   layout "workspace", only: [:show]
  
#   def index
#     @experiments = Experiment.all
#   end

#   def new
#     @experiment = Experiment.new
#   end
  
#   def edit
#   end

#   def create
#     @experiment = Experiment.new(experiment_params)

#     if @experiment.save
#       redirect_to experiments_url
#     else
#       render :new
#     end
#   end

#   def update
#     if @experiment.update(experiment_params)
#       redirect_to experiments_url
#     else
#       render :edit
#     end
#   end
  
#   private
  
#   def set_experiment
#     @experiment = Experiment.find(params[:id])
#   end

#   def experiment_params
#     # TODO: Unit test this
#     params[:experiment].permit(:name, :start_date, :end_date, :message_distribution_start_date, {:clinical_trial_ids => []})
#   end
# end
