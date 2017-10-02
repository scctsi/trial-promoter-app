class AddUrlToComments < ActiveRecord::Migration
  def change
    add_column :comments, :url, :string
  end
end
