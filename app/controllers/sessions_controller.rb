class SessionsController < ApplicationController
  layout "login", only: :new

  skip_before_action :require_login, only: %i[new create failure token_login]

  def new
    session[:native_auth] = true if params[:native] == "1"
  end

  def create
    user = User.from_omniauth(request.env["omniauth.auth"])

    if session.delete(:native_auth)
      login_token = LoginToken.create!(user: user)
      redirect_to "shouldplanner://auth/success?token=#{login_token.token}", allow_other_host: true
    else
      session[:user_id] = user.id
      redirect_to user.onboarding_completed? ? root_path : onboarding_path
    end
  end

  def token_login
    user = LoginToken.exchange(params[:token])
    if user
      session[:user_id] = user.id
      redirect_to user.onboarding_completed? ? root_path : onboarding_path
    else
      redirect_to login_path, alert: "Login link expired. Please try again."
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path
  end

  def failure
    redirect_to login_path, alert: "Authentication failed. Please try again."
  end
end
