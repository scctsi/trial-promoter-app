class MessageTemplatePolicy < ApplicationPolicy
  def import?
    user.role.administrator?
  end

  def set_message_template?
    user.role.administrator?
  end
  
  def get_image_pool_urls?
    user.role.administrator?
  end
end