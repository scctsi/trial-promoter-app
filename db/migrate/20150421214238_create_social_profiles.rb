class CreateSocialProfiles < ActiveRecord::Migration
  def change
    create_table :social_profiles do |t|
      t.string :network_name
      t.string :username

      t.timestamps null: false
    end
  end
end
