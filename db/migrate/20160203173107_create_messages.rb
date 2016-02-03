class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :clinical_trial
      t.references :message_template
      t.text :content
      t.string :tracking_url, limit: 2000

      t.datetime :sent_to_buffer_at
      t.datetime :sent_from_buffer_at
      t.string :buffer_update_id
      t.string :platform_update_id
      # t.datetime "scheduled_at"
      # t.string   "campaign"
      # t.string   "medium"
      # t.boolean  "image_required"
      # t.string   "image_url",           limit: 2000
      # t.string   "thumbnail_url",       limit: 2000
      # t.text     "statistics"
      # t.text     "service_statistics"

      t.timestamps null: false
    end
  end
end
