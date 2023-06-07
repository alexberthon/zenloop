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

ActiveRecord::Schema[7.0].define(version: 2023_06_07_091339) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "city_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_activities_on_city_id"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.string "country"
    t.integer "population"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "journeys", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.integer "likes"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "station_start_id", null: false
    t.bigint "station_end_id", null: false
    t.index ["station_end_id"], name: "index_journeys_on_station_end_id"
    t.index ["station_start_id"], name: "index_journeys_on_station_start_id"
    t.index ["user_id"], name: "index_journeys_on_user_id"
  end

  create_table "lines", force: :cascade do |t|
    t.bigint "station_start_id", null: false
    t.bigint "station_end_id", null: false
    t.datetime "dt_start"
    t.datetime "dt_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration"
    t.index ["station_end_id"], name: "index_lines_on_station_end_id"
    t.index ["station_start_id"], name: "index_lines_on_station_start_id"
  end

  create_table "stations", force: :cascade do |t|
    t.string "name"
    t.bigint "city_id", null: false
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "db_stop_id"
    t.index ["city_id"], name: "index_stations_on_city_id"
  end

  create_table "stays", force: :cascade do |t|
    t.datetime "dt_start"
    t.datetime "dt_end"
    t.bigint "city_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration"
    t.index ["city_id"], name: "index_stays_on_city_id"
  end

  create_table "steps", force: :cascade do |t|
    t.integer "order"
    t.bigint "journey_id", null: false
    t.string "type"
    t.bigint "line_id", null: false
    t.bigint "stay_id", null: false
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["journey_id"], name: "index_steps_on_journey_id"
    t.index ["line_id"], name: "index_steps_on_line_id"
    t.index ["stay_id"], name: "index_steps_on_stay_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "cities"
  add_foreign_key "journeys", "stations", column: "station_end_id"
  add_foreign_key "journeys", "stations", column: "station_start_id"
  add_foreign_key "journeys", "users"
  add_foreign_key "lines", "stations", column: "station_end_id"
  add_foreign_key "lines", "stations", column: "station_start_id"
  add_foreign_key "stations", "cities"
  add_foreign_key "stays", "cities"
  add_foreign_key "steps", "journeys"
  add_foreign_key "steps", "lines"
  add_foreign_key "steps", "stays"
end
