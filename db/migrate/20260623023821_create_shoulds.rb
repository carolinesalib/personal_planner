class CreateShoulds < ActiveRecord::Migration[8.0]
  def change
    create_table :shoulds do |t|
      t.string :title, null: false
      t.boolean :completed, null: false, default: false
      t.datetime :completed_at
      t.integer :position

      t.timestamps
    end

    add_index :shoulds, :completed
    add_index :shoulds, :position
  end
end
