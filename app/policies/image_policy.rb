class ImagePolicy < ApplicationPolicy
  def initialize(user, experiment, image)
    @user = user
    @experiment = experiment
    @image = image
  end

  def import?
    false
  end
end