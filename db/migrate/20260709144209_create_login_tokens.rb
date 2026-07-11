class CreateLoginTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :login_tokens do |t|
      t.string :token, null: false
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :login_tokens, :token, unique: true
  end
end
