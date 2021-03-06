class MessageTemplatePolicy < ApplicationPolicy
  def new?
    user.role.administrator?
  end
    
  def edit?
    user.role.administrator?
  end
      
  def update?
    user.role.administrator?
  end
      
  def create?
    user.role.administrator?
  end
  
  def import?
    user.role.administrator?
  end

  def set_message_template?
    user.role.administrator?
  end
  
  def get_image_selections?
    user.role.administrator?
  end
  
  def add_image_to_image_pool?
    user.role.administrator?
  end

  def remove_image_from_image_pool?
    user.role.administrator?
  end
end