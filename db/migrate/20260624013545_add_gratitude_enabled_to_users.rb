class AddGratitudeEnabledToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :gratitude_enabled, :boolean, null: false, default: false
  end
end
