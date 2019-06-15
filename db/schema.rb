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

ActiveRecord::Schema.define(version: 2019_06_14_233721) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

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

# Could not dump table "users" because of following StandardError
#   Unknown type 'bool' for column 'export_excel'

end
