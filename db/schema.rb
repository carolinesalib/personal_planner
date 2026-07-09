# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_07_09_023608) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "plan_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "date", null: false
    t.string "kind", null: false
    t.string "title", null: false
    t.boolean "completed", default: false, null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "date", "kind"], name: "index_plan_items_on_user_id_and_date_and_kind"
    t.index ["user_id"], name: "index_plan_items_on_user_id"
  end

  create_table "shoulds", force: :cascade do |t|
    t.string "title", null: false
    t.boolean "completed", default: false, null: false
    t.datetime "completed_at"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["completed"], name: "index_shoulds_on_completed"
    t.index ["position"], name: "index_shoulds_on_position"
    t.index ["user_id"], name: "index_shoulds_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "email", null: false
    t.string "name"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "gratitude_enabled", default: false, null: false
    t.string "locale", default: "en", null: false
    t.boolean "onboarding_completed", default: false, null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "plan_items", "users"
  add_foreign_key "shoulds", "users"
end
