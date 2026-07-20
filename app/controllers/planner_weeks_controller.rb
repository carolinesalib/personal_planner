class PlannerWeeksController < ApplicationController
  include PlannerPeriodLoadable

  layout "planner_desktop"

  def show
    @monday = params[:date] ? Planner::PeriodKey.monday_of(Date.parse(params[:date])) : Planner::PeriodKey.monday_of(Date.current)
    @sunday = @monday + 6.days
    @period_key = Planner::PeriodKey.week_key(@monday)

    @categories = load_categories("week", @period_key)
    @period = PlannerPeriod.find_or_create_for(current_user, "week", @period_key)

    @prev_path = planner_week_on_path(date: (@monday - 7.days).iso8601)
    @next_path = planner_week_on_path(date: (@monday + 7.days).iso8601)
    @this_path = planner_week_path
  end
end
