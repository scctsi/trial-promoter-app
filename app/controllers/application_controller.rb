class ApplicationController < ActionController::Base
  before_filter :set_timezone

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session if !(Rails.env == 'development')
  include Pundit

  before_action :always_login_fake_user if Rails.env == 'development'
  before_action :authenticate_user! if !(Rails.env == 'development')
  after_action :verify_authorized, unless: :devise_controller?, except: :index
  after_action :verify_policy_scoped, only: :index
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def set_timezone
    Time.zone = ActiveSupport::TimeZone["America/Los_Angeles"]
  end

  private

  def always_login_fake_user
    user = User.create_with(password: "123456", password_confirmation: "123456").find_or_create_by(email: "faker@faker.com")
    sign_in user
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action. Please contact your administrator for more information."
    redirect_to(request.referrer || root_path)
  end
end


