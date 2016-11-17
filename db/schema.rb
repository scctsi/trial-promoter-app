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

ActiveRecord::Schema.define(version: 20161117202013) do

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

  create_table "campaigns_clinical_trials", force: :cascade do |t|
    t.integer "campaign_id"
    t.integer "clinical_trial_id"
  end

  add_index "campaigns_clinical_trials", ["campaign_id"], name: "index_campaigns_clinical_trials_on_campaign_id", using: :btree
  add_index "campaigns_clinical_trials", ["clinical_trial_id"], name: "index_campaigns_clinical_trials_on_clinical_trial_id", using: :btree

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

  create_table "clinical_trials_experiments", force: :cascade do |t|
    t.integer "experiment_id"
    t.integer "clinical_trial_id"
  end

  add_index "clinical_trials_experiments", ["clinical_trial_id"], name: "index_clinical_trials_experiments_on_clinical_trial_id", using: :btree
  add_index "clinical_trials_experiments", ["experiment_id"], name: "index_clinical_trials_experiments_on_experiment_id", using: :btree

  create_table "experiments", force: :cascade do |t|
    t.string   "name",                            limit: 1000
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "message_distribution_start_date"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "experiments_websites", force: :cascade do |t|
    t.integer "experiment_id"
    t.integer "website_id"
  end

  add_index "experiments_websites", ["experiment_id"], name: "index_experiments_websites_on_experiment_id", using: :btree
  add_index "experiments_websites", ["website_id"], name: "index_experiments_websites_on_website_id", using: :btree

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
    t.string   "promoted_websites_tag"
    t.string   "promoted_clinical_trials_tag"
    t.string   "promoted_properties_cycle_type"
    t.string   "selected_message_templates_tag"
    t.string   "selected_message_templates_cycle_type"
    t.string   "medium_cycle_type"
    t.string   "social_network_cycle_type"
    t.string   "image_present_cycle_type"
    t.integer  "period_in_days"
    t.integer  "number_of_messages_per_social_network"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "message_generating_id"
    t.string   "message_generating_type"
  end

  add_index "message_generation_parameter_sets", ["message_generating_type", "message_generating_id"], name: "index_on_message_generating_type_and_message_generating_id", using: :btree

  create_table "message_templates", force: :cascade do |t|
    t.text     "content"
    t.string   "platform"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "clinical_trial_id"
    t.integer  "message_template_id"
    t.text     "content"
    t.string   "tracking_url",        limit: 2000
    t.string   "status"
    t.text     "buffer_profile_ids"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "website_id"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

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
    t.string   "title",      limit: 1000
    t.string   "url",        limit: 2000
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

end
