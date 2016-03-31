class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :clinical_trial
      t.references :message_template
      t.text :text
      t.string :tracking_url, limit: 2000
      t.string :status

      t.text :buffer_profile_ids
      # t.datetime "scheduled_at"
      # t.string   "campaign"
      # t.string   "medium"
      # t.boolean  "image_required"
      # t.string   "image_url",           limit: 2000
      # t.string   "thumbnail_url",       limit: 2000

      t.timestamps null: false
    end
  end
end
