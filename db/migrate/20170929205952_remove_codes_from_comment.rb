class RemoveCodesFromComment < ActiveRecord::Migration
  def change
    remove_column :comments, :codes, :text
  end
end
