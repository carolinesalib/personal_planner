class RenameNameToTitleOnPlannerCategories < ActiveRecord::Migration[8.0]
  def change
    rename_column :planner_categories, :name, :title
  end
end
