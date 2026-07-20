module PlannerPeriodLoadable
  extend ActiveSupport::Concern

  private

  def load_categories(period_type, period_key)
    Planner::PeriodSeeder.call(user: current_user, period_type: period_type, period_key: period_key)
    current_user.planner_categories
      .for_period(period_type, period_key)
      .includes(:planner_items)
  end
end
