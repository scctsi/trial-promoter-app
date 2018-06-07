class AddSocialMediaUserIdToComment < ActiveRecord::Migration
  def change
    add_column :comments, :social_media_user_id, :string
  end
end
