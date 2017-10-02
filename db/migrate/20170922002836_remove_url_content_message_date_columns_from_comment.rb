class RemoveUrlContentMessageDateColumnsFromComment < ActiveRecord::Migration
  def change
    remove_column :comments, :url
    remove_column :comments, :message_date
    remove_column :comments, :content
  end
end
