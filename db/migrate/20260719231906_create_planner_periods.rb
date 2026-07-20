class CreatePlannerPeriods < ActiveRecord::Migration[8.0]
  def change
    create_table :planner_periods do |t|
      t.references :user, null: false, foreign_key: true
      t.string :period_type, null: false
      t.string :period_key, null: false
      t.string :mission

      t.timestamps
    end

    add_index :planner_periods, [ :user_id, :period_type, :period_key ], unique: true, name: "index_planner_periods_on_user_and_period"
  end
end
