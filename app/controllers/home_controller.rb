class HomeController < ApplicationController
  def index
    authorize  :home, :index?
    @experiments = policy_scope(Experiment)
  end
end
