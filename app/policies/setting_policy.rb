class SettingPolicy < ApplicationPolicy
  def index?
    user.role.administrator?
  end

  def get_setting?
    user.role.administrator?
  end
end