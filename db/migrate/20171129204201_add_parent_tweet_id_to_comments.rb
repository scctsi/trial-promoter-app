class AddParentTweetIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :parent_tweet_id, :string
  end
end
