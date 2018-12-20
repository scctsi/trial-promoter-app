class SessionsController < ApplicationController
  skip_after_action :verify_authorized
  
  def create
    @auth = request.env['omniauth.auth']
    @params = request.env['omniauth.params']
    
    p @auth
    p @params
  end
end