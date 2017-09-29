class AddCodesToComment < ActiveRecord::Migration
  def change
    add_column :comments, :codes, :text
  end
end
