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

<<<<<<< HEAD
ActiveRecord::Schema.define(version: 20171129204201) do
=======
ActiveRecord::Schema.define(version: 20171108005622) do
>>>>>>> development

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ahoy_events", force: :cascade do |t|
    t.integer  "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.datetime "time"
    t.jsonb    "properties"
  end

  add_index "ahoy_events", ["name", "time"], name: "index_ahoy_events_on_name_and_time", using: :btree
  add_index "ahoy_events", ["user_id", "name"], name: "index_ahoy_events_on_user_id_and_name", using: :btree
  add_index "ahoy_events", ["visit_id", "name"], name: "index_ahoy_events_on_visit_id_and_name", using: :btree

  create_table "analytics_file_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "analytics_files", force: :cascade do |t|
    t.string   "url",                     limit: 2000
    t.string   "original_filename"
    t.integer  "social_media_profile_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.datetime "required_upload_date"
    t.integer  "message_generating_id"
    t.string   "message_generating_type"
    t.string   "processing_status"
    t.integer  "analytics_file_set_id"
  end

  create_table "buffer_updates", force: :cascade do |t|
    t.string   "buffer_id"
    t.string   "service_update_id"
    t.string   "status"
    t.integer  "message_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.datetime "sent_from_date_time"
    t.text     "published_text"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "name",       limit: 1000
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "click_meter_tracking_links", force: :cascade do |t|
    t.string   "click_meter_id"
    t.string   "click_meter_uri", limit: 2000
    t.string   "tracking_url",    limit: 2000
    t.string   "destination_url", limit: 2000
    t.integer  "message_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "clicks", force: :cascade do |t|
    t.datetime "click_time"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "click_meter_event_id"
    t.boolean  "spider"
    t.boolean  "unique"
    t.integer  "click_meter_tracking_link_id"
    t.text     "ip_address"
  end

  add_index "clicks", ["click_meter_tracking_link_id"], name: "index_clicks_on_click_meter_tracking_link_id", using: :btree

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

  create_table "comments", force: :cascade do |t|
    t.datetime "comment_date"
    t.text     "comment_text"
    t.text     "commentator_username"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "toxicity_score"
    t.integer  "message_id"
    t.string   "social_media_comment_id"
    t.string   "commentator_id"
    t.string   "parent_tweet_id"
  end

  create_table "daily_metric_parser_results", force: :cascade do |t|
    t.date     "file_date"
    t.text     "file_path"
    t.text     "parsed_data"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "data_dictionaries", force: :cascade do |t|
    t.integer  "experiment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "data_dictionary_entries", force: :cascade do |t|
    t.boolean  "include_in_report"
    t.string   "variable_name"
    t.string   "report_label"
    t.string   "integrity_check"
    t.string   "source"
    t.text     "note"
    t.integer  "data_dictionary_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.text     "allowed_values"
    t.text     "value_mapping"
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

  create_table "experiments", force: :cascade do |t|
    t.string   "name",                            limit: 1000
    t.datetime "end_date"
    t.datetime "message_distribution_start_date"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.text     "twitter_posting_times"
    t.text     "facebook_posting_times"
    t.text     "instagram_posting_times"
    t.integer  "click_meter_group_id"
    t.integer  "click_meter_domain_id"
    t.text     "comment_codes"
    t.text     "image_codes"
    t.text     "ip_exclusion_list"
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

  create_table "image_replacements", force: :cascade do |t|
    t.integer  "message_id"
    t.integer  "previous_image_id"
    t.integer  "replacement_image_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "images", force: :cascade do |t|
    t.string   "url",                             limit: 2000
    t.string   "original_filename"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "width"
    t.integer  "height"
    t.boolean  "meets_instagram_ad_requirements"
    t.integer  "duplicated_image_id"
  end

  create_table "message_generation_parameter_sets", force: :cascade do |t|
    t.integer  "period_in_days"
    t.integer  "number_of_messages_per_social_network"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "message_generating_id"
    t.string   "message_generating_type"
    t.text     "social_network_choices"
    t.text     "medium_choices"
    t.text     "image_present_choices"
    t.integer  "number_of_cycles"
  end

  add_index "message_generation_parameter_sets", ["message_generating_type", "message_generating_id"], name: "index_on_message_generating_type_and_message_generating_id", using: :btree

  create_table "message_templates", force: :cascade do |t|
    t.text     "content"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.text     "hashtags"
    t.text     "experiment_variables"
    t.text     "image_pool"
    t.text     "original_image_filenames"
    t.text     "platforms"
    t.string   "promoted_website_url",     limit: 2000
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "message_template_id"
    t.text     "content"
    t.string   "tracking_url",                 limit: 2000
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "website_id"
    t.integer  "message_generating_id"
    t.string   "message_generating_type"
    t.integer  "promotable_id"
    t.string   "promotable_type"
    t.string   "medium"
    t.string   "image_present"
    t.integer  "image_id"
    t.string   "publish_status"
    t.datetime "scheduled_date_time"
    t.string   "social_network_id"
    t.integer  "social_media_profile_id"
    t.string   "platform"
    t.string   "promoted_website_url",         limit: 2000
    t.string   "campaign_id"
    t.boolean  "backdated"
    t.datetime "original_scheduled_date_time"
    t.float    "click_rate"
    t.float    "website_goal_rate"
    t.integer  "website_goal_count"
    t.integer  "website_session_count"
    t.text     "impressions_by_day"
    t.text     "note"
  end

  add_index "messages", ["message_generating_type", "message_generating_id"], name: "index_on_message_generating_for_analytics_files", using: :btree
  add_index "messages", ["message_generating_type", "message_generating_id"], name: "index_on_message_generating_for_messages", using: :btree
  add_index "messages", ["promotable_type", "promotable_id"], name: "index_on_promotable_for_messages", using: :btree

  create_table "metrics", force: :cascade do |t|
    t.string   "source"
    t.text     "data"
    t.integer  "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "modifications", force: :cascade do |t|
    t.integer  "experiment_id"
    t.string   "description"
    t.text     "details"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
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
    t.string   "allowed_mediums"
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

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",     null: false
    t.string   "encrypted_password",     default: "",     null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,      null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "role",                   default: "user", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "visits", force: :cascade do |t|
    t.string   "visit_token"
    t.string   "visitor_token"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.integer  "screen_height"
    t.integer  "screen_width"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "postal_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
  end

  add_index "visits", ["user_id"], name: "index_visits_on_user_id", using: :btree
  add_index "visits", ["visit_token"], name: "index_visits_on_visit_token", unique: true, using: :btree

  add_foreign_key "clicks", "click_meter_tracking_links"
  add_foreign_key "messages", "social_media_profiles"
end
