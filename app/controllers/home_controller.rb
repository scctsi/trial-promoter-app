class HomeController < ApplicationController
  skip_after_action :verify_authorized
  def index
    @campaigns = Campaign.all
    @experiments = Experiment.all
  end
end
