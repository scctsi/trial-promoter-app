class AddSocialMediaProfileToMessages < ActiveRecord::Migration
  def change
    add_reference :messages, :social_media_profile, foreign_key: true
  end
end
