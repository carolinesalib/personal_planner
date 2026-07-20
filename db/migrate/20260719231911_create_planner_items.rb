class CreatePlannerItems < ActiveRecord::Migration[8.0]
  def change
    create_table :planner_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :planner_category, null: false, foreign_key: true
      t.string :title, null: false
      t.boolean :completed, default: false, null: false
      t.integer :position

      t.timestamps
    end
  end
end
