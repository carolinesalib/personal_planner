class CreatePlannerCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :planner_categories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :period_type, null: false
      t.string :period_key, null: false
      t.string :name, null: false
      t.integer :position

      t.timestamps
    end

    add_index :planner_categories, [ :user_id, :period_type, :period_key ], name: "index_planner_categories_on_user_and_period"
  end
end
