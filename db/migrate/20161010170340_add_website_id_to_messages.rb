class AddWebsiteIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :website_id, :integer
  end
end
