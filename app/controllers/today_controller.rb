class TodayController < ApplicationController
  def show
    @date = Date.current
    items = current_user.plan_items.for_date(@date)
    @priorities = items.priorities
    @extras = items.extras
    @gratitude_items = items.gratitudes
    trackable = items.trackable
    @total = trackable.count
    @done = trackable.where(completed: true).count
  end
end
