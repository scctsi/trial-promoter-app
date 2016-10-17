class MessageGenerationParameterSetsController < ApplicationController
  def new
    @message_generation_parameter_set = MessageGenerationParameterSet.new
  end
end
