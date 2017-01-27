class CreateAnalyticsFiles < ActiveRecord::Migration
  def change
    create_table :analytics_files do |t|
      t.string :url, limit: 2000
      t.string :original_filename
      t.references :social_media_profile

      t.timestamps null: false
    end
  end
end
