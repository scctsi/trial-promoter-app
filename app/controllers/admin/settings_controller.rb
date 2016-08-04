class Admin::SettingsController < ApplicationController
  # TODO: Unit test this controller
  before_action :get_setting, only: [:edit, :update]
  
  def index
    @settings = Setting.get_all
  end
  
  def edit
  end
  
  def update
    if @setting.value != params[:setting][:value]
      @setting.value = params[:setting][:value]
      @setting.save
      redirect_to admin_settings_path, notice: 'Setting has been updated.'
    else
      redirect_to admin_settings_path
    end
  end
  
  def get_setting
    @setting = Setting.find_by(var: params[:id]) || Setting.new(var: params[:id])
  end
end
