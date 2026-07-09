class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :require_login
  before_action :redirect_to_onboarding

  private

  def require_login
    redirect_to login_path unless current_user
  end

  def redirect_to_onboarding
    return unless current_user
    return if current_user.onboarding_completed?
    return if controller_name.in?(%w[onboarding sessions])

    redirect_to onboarding_path
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  helper_method :current_user
end
