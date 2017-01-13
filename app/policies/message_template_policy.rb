class MessageTemplatePolicy < ApplicationPolicy
  def initialize(user, message_template, experiment)
    @user = user
    @message_template = message_template
    @experiment = experiment
  end

  def show?
    false
  end

  def import?
    false
  end

  def set_message_template?
    false
  end
end