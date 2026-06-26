class CreatePlanItems < ActiveRecord::Migration[8.0]
  def change
    create_table :plan_items do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.string :kind, null: false
      t.string :title, null: false
      t.boolean :completed, default: false, null: false
      t.integer :position

      t.timestamps
    end

    add_index :plan_items, %i[user_id date kind]
  end
end
