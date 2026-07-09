class OnboardingController < ApplicationController
  layout "onboarding"

  TOTAL_STEPS = 5

  def show
    redirect_to root_path if current_user.onboarding_completed?
    @step = (params[:step] || 1).to_i.clamp(1, TOTAL_STEPS)
  end

  def complete
    current_user.update!(onboarding_completed: true, gratitude_enabled: params[:gratitude_enabled] == "1")
    redirect_to root_path
  end
end
