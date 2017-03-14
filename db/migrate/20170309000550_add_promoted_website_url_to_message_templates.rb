class AddPromotedWebsiteUrlToMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :url, :string, limit: 2000
  end
end
