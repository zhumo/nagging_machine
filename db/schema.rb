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

ActiveRecord::Schema.define(version: 20150424022941) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "nags", force: true do |t|
    t.string   "contents",                                       null: false
    t.string   "status",         default: "active",              null: false
    t.integer  "ping_count",     default: 0,                     null: false
    t.integer  "user_id",                                        null: false
    t.datetime "last_ping_time", default: '1970-01-01 00:00:00'
    t.datetime "next_ping_time", default: '1970-01-01 00:00:00'
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "encrypted_password",     default: "",                      null: false
    t.integer  "sign_in_count",          default: 0,                       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone_number",                                             null: false
    t.string   "first_name",                                               null: false
    t.string   "last_name",                                                null: false
    t.string   "status",                 default: "awaiting confirmation", null: false
    t.string   "confirmation_code"
    t.datetime "confirmation_code_time"
    t.string   "auth_token"
  end

end
