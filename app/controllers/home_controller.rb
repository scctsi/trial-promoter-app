class HomeController < ApplicationController
  def index
    authorize  :home, :index?
    @campaigns = Campaign.all
    @experiments = Experiment.all
  end
end
