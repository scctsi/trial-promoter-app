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

ActiveRecord::Schema.define(version: 20161222185101) do

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

  create_table "campaigns", force: :cascade do |t|
    t.string   "name",       limit: 1000
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
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
    t.text     "hashtags"
  end

  create_table "experiments", force: :cascade do |t|
    t.string   "name",                            limit: 1000
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "message_distribution_start_date"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "experiments_social_media_profiles", force: :cascade do |t|
    t.integer "experiment_id"
    t.integer "social_media_profile_id"
  end

  add_index "experiments_social_media_profiles", ["experiment_id", "social_media_profile_id"], name: "index_experiments_social_media_profiles", unique: true, using: :btree

  create_table "hashtags", force: :cascade do |t|
    t.string   "phrase"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "images", force: :cascade do |t|
    t.string   "url",               limit: 2000
    t.string   "original_filename"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "message_generation_parameter_sets", force: :cascade do |t|
    t.string   "medium_distribution"
    t.string   "social_network_distribution"
    t.string   "image_present_distribution"
    t.integer  "period_in_days"
    t.integer  "number_of_messages_per_social_network"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "message_generating_id"
    t.string   "message_generating_type"
    t.text     "social_network_choices"
    t.text     "medium_choices"
    t.text     "image_present_choices"
  end

  add_index "message_generation_parameter_sets", ["message_generating_type", "message_generating_id"], name: "index_on_message_generating_type_and_message_generating_id", using: :btree

  create_table "message_templates", force: :cascade do |t|
    t.text     "content"
    t.string   "platform"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "hashtags"
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "message_template_id"
    t.text     "content"
    t.string   "tracking_url",            limit: 2000
    t.text     "buffer_profile_ids"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "website_id"
    t.integer  "message_generating_id"
    t.string   "message_generating_type"
    t.integer  "promotable_id"
    t.string   "promotable_type"
    t.string   "medium"
    t.string   "image_present"
    t.integer  "image_id"
    t.string   "publish_status"
    t.datetime "buffer_publish_date"
    t.datetime "social_network_publish_date"

  add_index "messages", ["message_generating_type", "message_generating_id"], name: "index_on_message_generating_for_messages", using: :btree
  add_index "messages", ["promotable_type", "promotable_id"], name: "index_on_promotable_for_messages", using: :btree

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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "social_media_profiles", force: :cascade do |t|
    t.string   "platform"
    t.string   "service_id"
    t.string   "service_type"
    t.string   "service_username"
    t.string   "buffer_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
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

  add_index "taggings", ["context"], name: "index_taggings_on_context", using: :btree
  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
  add_index "taggings", ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
  add_index "taggings", ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
  add_index "taggings", ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
  add_index "taggings", ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "websites", force: :cascade do |t|
    t.string   "name",       limit: 1000
    t.string   "url",        limit: 2000
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

end
