class RemoveSocialMediaUserIdFromComment < ActiveRecord::Migration
  def change
    remove_column :comments, :social_media_user_id, :string
  end
end
