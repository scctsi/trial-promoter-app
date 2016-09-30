class HomeController < ApplicationController
  def index
    @campaigns = Campaign.all
    @experiments = Experiment.all
  end
end
