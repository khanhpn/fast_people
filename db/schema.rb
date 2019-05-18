# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_18_144921) do

  create_table "error_users", force: :cascade do |t|
    t.string "model_family"
    t.string "name"
    t.string "zip_code"
    t.text "link"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "id_user_info"
  end

  create_table "master_data", force: :cascade do |t|
    t.string "model_family"
    t.string "name"
    t.string "zip_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "id_user_info"
    t.index ["model_family"], name: "index_master_data_on_model_family"
    t.index ["name"], name: "index_master_data_on_name"
    t.index ["zip_code"], name: "index_master_data_on_zip_code"
  end

  create_table "proxies", force: :cascade do |t|
    t.string "name"
    t.integer "port"
    t.boolean "elite", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["elite"], name: "index_proxies_on_elite"
  end

  create_table "raw_data", force: :cascade do |t|
    t.text "raw_url"
    t.text "proxy_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "age"
    t.text "emails"
    t.text "landline"
    t.text "wireless"
    t.text "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "model_family"
    t.string "zip_code"
    t.string "name"
    t.string "id_user_info"
  end

end
