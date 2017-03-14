class AddPromotedWebsiteUrlToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :promoted_website_url, :string, limit: 2000
  end
end
