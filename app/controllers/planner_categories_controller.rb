class PlannerCategoriesController < ApplicationController
  before_action :set_category, only: %i[update destroy]

  def create
    @category = current_user.planner_categories.new(category_params)
    @category.position = current_user.planner_categories
      .where(period_type: @category.period_type, period_key: @category.period_key).count
    if @category.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path }
      end
    else
      redirect_back fallback_location: root_path
    end
  end

  def update
    if @category.update(category_params.slice(:title))
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path }
      end
    else
      redirect_back fallback_location: root_path
    end
  end

  def destroy
    @period_type = @category.period_type
    @period_key = @category.period_key
    @category.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  private

  def set_category
    @category = current_user.planner_categories.find(params[:id])
  end

  def category_params
    params.require(:planner_category).permit(:title, :period_type, :period_key)
  end
end
