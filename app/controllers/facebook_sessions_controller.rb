require 'pry'

class FacebookSessionsController < ApplicationController
  skip_after_action :verify_authorized
  
  def facebook_create
    experiment_id = request.env["omniauth.params"]["state"]
    token = request.env["omniauth.auth"]["credentials"]["token"]
    experiment = Experiment.find(experiment_id)
    experiment.set_facebook_keys(token)
    binding.pry;
    redirect_to '/'
  end
end