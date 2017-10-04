class RemoveCodesFromImage < ActiveRecord::Migration
  def change
    remove_column :images, :codes, :text
  end
end
