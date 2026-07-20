class PlannerItemsController < ApplicationController
  before_action :set_item, only: %i[update destroy toggle]

  def create
    @category = current_user.planner_categories.find(params[:planner_item][:planner_category_id])
    @item = @category.planner_items.new(item_params.except(:planner_category_id))
    @item.user = current_user
    @item.position = @category.planner_items.count
    if @item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path }
      end
    else
      redirect_back fallback_location: root_path
    end
  end

  def update
    @category = @item.planner_category
    if @item.update(item_params.slice(:title))
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path }
      end
    else
      redirect_back fallback_location: root_path
    end
  end

  def destroy
    @category = @item.planner_category
    @item.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def toggle
    @category = @item.planner_category
    @item.update!(completed: !@item.completed)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  private

  def set_item
    @item = current_user.planner_items.find(params[:id])
  end

  def item_params
    params.require(:planner_item).permit(:title, :planner_category_id)
  end
end
