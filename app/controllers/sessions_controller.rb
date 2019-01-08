class SessionsController < ApplicationController
  skip_after_action :verify_authorized
  
  def facebook_create
    experiment = Experiment.find(request.env["omniauth.params"]["experiment_id"].to_i)
p experiment
    redirect_to '/'
  end
end