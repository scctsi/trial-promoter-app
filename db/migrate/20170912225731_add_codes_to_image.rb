class AddCodesToImage < ActiveRecord::Migration
  def change
    add_column :images, :codes, :text
  end
end
