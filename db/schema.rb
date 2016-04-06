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

ActiveRecord::Schema.define(version: 20160331220214) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "buffer_updates", force: :cascade do |t|
    t.string   "buffer_id"
    t.string   "service_update_id"
    t.string   "status"
    t.integer  "message_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "clinical_trials", force: :cascade do |t|
    t.string   "title",            limit: 1000
    t.string   "pi_first_name"
    t.string   "pi_last_name"
    t.string   "url",              limit: 2000
    t.string   "nct_id"
    t.string   "disease"
    t.datetime "last_promoted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "message_templates", force: :cascade do |t|
    t.text     "content"
    t.string   "platform"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "clinical_trial_id"
    t.integer  "message_template_id"
    t.text     "text"
    t.string   "tracking_url",        limit: 2000
    t.string   "status"
    t.text     "buffer_profile_ids"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "metrics", force: :cascade do |t|
    t.string   "source"
    t.text     "data"
    t.integer  "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

end
