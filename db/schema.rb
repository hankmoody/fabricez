# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20120302064308) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "adminpack"

  create_table "collections", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collections_fabrics", id: false, force: true do |t|
    t.integer "collection_id"
    t.integer "fabric_id"
  end

  create_table "colors", force: true do |t|
    t.integer  "red"
    t.integer  "green"
    t.integer  "blue"
    t.float    "ciel_L"
    t.float    "ciel_a"
    t.float    "ciel_b"
    t.integer  "fabric_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "details", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company_name"
    t.string   "address1"
    t.string   "address2"
    t.string   "address3"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.string   "zip"
    t.string   "phone"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
  end

  create_table "fabrics", force: true do |t|
    t.string   "code"
    t.integer  "width"
    t.decimal  "price",                   precision: 9, scale: 2
    t.decimal  "quantity",                precision: 9, scale: 2
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",                                       default: false
    t.boolean  "processed",                                       default: false
    t.integer  "crop_x",                                          default: 0
    t.integer  "crop_y",                                          default: 0
    t.integer  "crop_w",                                          default: 600
    t.integer  "crop_h",                                          default: 400
  end

  create_table "fabrics_tags", id: false, force: true do |t|
    t.integer "tag_id"
    t.integer "fabric_id"
  end

  create_table "reed_picks", force: true do |t|
    t.integer  "reed"
    t.integer  "pick"
    t.integer  "fabric_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "category"
    t.integer  "limit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.string   "name"
    t.string   "tagtype"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "username"
    t.string   "usertype"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "yarn_counts", force: true do |t|
    t.integer  "warp_ply_count"
    t.integer  "weft_ply_count"
    t.integer  "warp_yarn_thickness"
    t.integer  "weft_yarn_thickness"
    t.integer  "fabric_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
