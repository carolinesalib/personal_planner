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
    @can_reset = resettable?(@monday)
    @can_copy_previous = seeder_for(@period_key).previous_period_categories?
  end

  # Clears the week and rebuilds it, either by copying the previous week or from
  # the default categories. See Planner::PeriodReset.
  def reset
    monday = Planner::PeriodKey.monday_of(Date.parse(params[:date]))
    period_key = Planner::PeriodKey.week_key(monday)

    # Hiding the button isn't enough on its own, the route is reachable directly.
    return redirect_to planner_week_on_path(date: monday.iso8601) unless resettable?(monday)

    begin
      Planner::PeriodReset.call(
        user: current_user, period_type: "week",
        period_key: period_key, strategy: params[:strategy]
      )
    rescue ArgumentError
      # Unrecognised strategy, fall through to the unchanged week.
    end

    redirect_to planner_week_on_path(date: monday.iso8601)
  end

  private

  # Past weeks are a record of what happened, so they can't be cleared. The
  # current week and any future week can, including an empty future week, which
  # is how you pull this week's plan forward to plan ahead.
  def resettable?(monday)
    monday >= Planner::PeriodKey.monday_of(Date.current)
  end

  def seeder_for(period_key)
    Planner::PeriodSeeder.new(user: current_user, period_type: "week", period_key: period_key)
  end
end
