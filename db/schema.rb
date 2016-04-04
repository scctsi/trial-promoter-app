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

ActiveRecord::Schema.define(version: 20151009201550) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clinical_trials", force: :cascade do |t|
    t.string   "title",                limit: 1000
    t.string   "pi_name"
    t.string   "url",                  limit: 2000
    t.string   "nct_id"
    t.string   "initial_database_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "randomization_status"
    t.text     "hashtags"
    t.string   "disease"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "dimension_metrics", force: :cascade do |t|
    t.text     "dimensions"
    t.text     "metrics"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "message_templates", force: :cascade do |t|
    t.text     "content"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "initial_id"
    t.string   "platform"
    t.string   "message_type"
  end

  create_table "messages", force: :cascade do |t|
    t.text     "content"
    t.integer  "clinical_trial_id"
    t.integer  "message_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "scheduled_at"
    t.string   "tracking_url",        limit: 2000
    t.string   "campaign"
    t.string   "medium"
    t.boolean  "image_required"
    t.string   "image_url",           limit: 2000
    t.string   "thumbnail_url",       limit: 2000
    t.datetime "sent_to_buffer_at"
    t.datetime "sent_from_buffer_at"
    t.string   "buffer_update_id"
    t.text     "statistics"
    t.string   "service_update_id"
    t.text     "service_statistics"
  end

  create_table "platforms", force: :cascade do |t|
    t.string   "name"
    t.string   "medium"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "social_profiles", force: :cascade do |t|
    t.string   "network_name"
    t.string   "username"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "urls", force: :cascade do |t|
    t.string   "value",      limit: 2000
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

end
