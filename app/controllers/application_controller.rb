class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  include Pundit

  before_action :authenticate_user!
  after_action :verify_authorized, unless: :devise_controller?
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized


  private

  def user_not_authorized
    if current_user.role == 'user'
      render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    else
      flash[:alert] = "You are not authorized to perform this action. Please contact your administrator for more information."
      redirect_to(request.referrer || root_path)
    end
  end
end


