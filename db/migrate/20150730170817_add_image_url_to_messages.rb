class AddImageUrlToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :image_required, :boolean
    add_column :messages, :image_url, :string, :limit => 2000
  end
end
