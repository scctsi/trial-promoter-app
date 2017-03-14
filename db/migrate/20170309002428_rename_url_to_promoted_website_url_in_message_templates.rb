class RenameUrlToPromotedWebsiteUrlInMessageTemplates < ActiveRecord::Migration
  def change
    rename_column :message_templates, :url, :promoted_website_url
  end
end
