class PlannerController < ApplicationController
  def index
    @year = (params[:year] || Date.current.year).to_i
    @month = (params[:month] || Date.current.month).to_i
    @first_of_month = Date.new(@year, @month, 1)
    @month_label = @first_of_month.strftime("%B %Y")

    start_date = @first_of_month.beginning_of_week(:sunday)
    end_date = (start_date + 41.days)

    items = current_user.plan_items.trackable.where(date: start_date..end_date)
    @day_stats = items.group(:date).select(
      "date",
      "COUNT(*) as total",
      "SUM(CASE WHEN completed THEN 1 ELSE 0 END) as done"
    ).index_by(&:date)

    @calendar_cells = build_calendar(start_date)
  end

  def show
    @date = Date.parse(params[:date])
    items = current_user.plan_items.for_date(@date)
    @priorities = items.priorities
    @extras = items.extras
    @gratitude_items = items.gratitudes
    trackable = items.trackable
    @total = trackable.count
    @done = trackable.where(completed: true).count
    @from_calendar = true
  end

  private

  def build_calendar(start_date)
    today = Date.current
    (0..41).map do |i|
      d = start_date + i.days
      in_month = d.month == @month
      is_today = d == today
      stats = @day_stats[d]
      total = stats&.total.to_i
      done = stats&.done.to_i
      has_plan = total > 0
      frac = has_plan ? done.to_f / total : 0
      deg = (frac * 360).round

      { date: d, day: d.day, in_month: in_month, is_today: is_today,
        has_plan: has_plan, deg: deg, frac: frac }
    end
  end
end
