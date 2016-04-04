class AddImageThumbnailLinkToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :thumbnail_url, :string, :limit => 2000
  end
end
