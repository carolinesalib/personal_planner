class PlannerPeriodsController < ApplicationController
  def update
    period = current_user.planner_periods.find(params[:id])
    period.update(period_params)
    head :ok
  end

  private

  def period_params
    params.require(:planner_period).permit(:mission)
  end
end
