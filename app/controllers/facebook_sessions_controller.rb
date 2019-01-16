class FacebookSessionsController < ApplicationController
  skip_after_action :verify_authorized
  
  def facebook_create
    experiment_id = request.env["omniauth.params"]["state"]
    token = request.env["omniauth.auth"]["credentials"]["token"]
    experiment = Experiment.find(experiment_id)
    experiment.set_facebook_keys(token)
    redirect_to '/'
  end
  
  def facebook_destroy
    experiment_id = request.env["omniauth.params"][:experiment_id]
    experiment = Experiment.find(experiment_id)
    experiment.settings(:facebook).update_attributes! :value => nil
    experiment.settings(:facebook).save!
    redirect_to '/'
  end
end