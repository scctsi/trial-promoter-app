class HomePolicy < ApplicationPolicy
  def initialize(user, experiment, campaign)
    @user = user
    @experiment = experiment
    @campaign = campaign
  end

  def index?
    false
  end
end