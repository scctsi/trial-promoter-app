class FixColumnNameInComments < ActiveRecord::Migration
  def change
    rename_column :comments, :message, :content
  end
end
