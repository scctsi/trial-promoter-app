class CreateSocialMediaProfiles < ActiveRecord::Migration
  def change
    create_table :social_media_profiles do |t|
      t.string :platform
      t.string :service_id
      t.string :service_type
      t.string :service_username
      t.string :buffer_id

      t.timestamps null: false
    end
  end
end
