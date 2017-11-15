class AddSocialMediaCommentIdToComment < ActiveRecord::Migration
  def change
    add_column :comments, :social_media_comment_id, :string
  end
end
