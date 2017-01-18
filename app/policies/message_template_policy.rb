class MessageTemplatePolicy < ApplicationPolicy
  def import?
    user.role.administrator?
  end

  def set_message_template?
    user.role.administrator?
  end
end