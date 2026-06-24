class SessionsController < ApplicationController
  layout "login", only: :new

  skip_before_action :require_login, only: %i[new create failure]

  def new
  end

  def create
    user = User.from_omniauth(request.env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path
  end

  def failure
    redirect_to login_path, alert: "Authentication failed. Please try again."
  end
end
