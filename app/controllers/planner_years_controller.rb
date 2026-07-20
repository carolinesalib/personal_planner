class PlannerYearsController < ApplicationController
  include PlannerPeriodLoadable

  layout "planner_desktop"

  def show
    @year = (params[:year] || Date.current.year).to_i
    @period_key = Planner::PeriodKey.year_key(@year)

    @categories = load_categories("year", @period_key)

    @prev_path = planner_year_on_path(year: @year - 1)
    @next_path = planner_year_on_path(year: @year + 1)
    @this_path = planner_year_path
  end
end
