class AddMediumImageReferenceAndImagePresentToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :medium, :string
    add_column :messages, :image_present, :string
    add_reference :messages, :image
  end
end
