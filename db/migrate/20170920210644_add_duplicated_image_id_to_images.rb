class AddDuplicatedImageIdToImages < ActiveRecord::Migration
  def change
    add_column :images, :duplicated_image_id, :integer
  end
end
