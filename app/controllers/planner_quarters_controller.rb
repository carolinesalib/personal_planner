class PlannerQuartersController < ApplicationController
  include PlannerPeriodLoadable

  layout "planner_desktop"

  def show
    if params[:year] && params[:q]
      @year = params[:year].to_i
      @quarter = params[:q].to_i
    else
      @year = Date.current.year
      @quarter = Planner::PeriodKey.quarter_of(Date.current)
    end
    @period_key = Planner::PeriodKey.quarter_key(@year, @quarter)

    @categories = load_categories("quarter", @period_key)

    prev_year, prev_quarter = shift_quarter(@year, @quarter, -1)
    next_year, next_quarter = shift_quarter(@year, @quarter, 1)
    @prev_path = planner_quarter_on_path(year: prev_year, q: prev_quarter)
    @next_path = planner_quarter_on_path(year: next_year, q: next_quarter)
    @this_path = planner_quarter_path
  end

  private

  def shift_quarter(year, quarter, delta)
    total = (year * 4) + (quarter - 1) + delta
    [ total / 4, (total % 4) + 1 ]
  end
end
