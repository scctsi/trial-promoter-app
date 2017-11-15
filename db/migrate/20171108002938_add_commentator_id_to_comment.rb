class AddCommentatorIdToComment < ActiveRecord::Migration
  def change
    add_column :comments, :commentator_id, :string
  end
end
