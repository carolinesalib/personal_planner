class PlanItemsController < ApplicationController
  before_action :set_plan_item, only: %i[update destroy toggle]

  def create
    @plan_item = current_user.plan_items.new(plan_item_params)
    @date = @plan_item.date
    if @plan_item.save
      load_plan_data
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: today_path }
      end
    else
      redirect_back fallback_location: today_path
    end
  end

  def update
    @date = @plan_item.date
    if @plan_item.update(plan_item_params.slice(:title))
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: today_path }
      end
    else
      redirect_back fallback_location: today_path
    end
  end

  def destroy
    @date = @plan_item.date
    @kind = @plan_item.kind
    @plan_item.destroy
    load_plan_data
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: today_path }
    end
  end

  def toggle
    @date = @plan_item.date
    @plan_item.update!(completed: !@plan_item.completed)
    load_plan_data
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: today_path }
    end
  end

  private

  def set_plan_item
    @plan_item = current_user.plan_items.find(params[:id])
  end

  def plan_item_params
    params.require(:plan_item).permit(:date, :kind, :title)
  end

  def load_plan_data
    items = current_user.plan_items.for_date(@date)
    @priorities = items.priorities
    @extras = items.extras
    @gratitude_items = items.gratitudes
    trackable = items.trackable
    @total = trackable.count
    @done = trackable.where(completed: true).count
  end
end
