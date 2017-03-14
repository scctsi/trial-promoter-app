class RemovePlatformFromMessageTemplates < ActiveRecord::Migration
  def change
    remove_column :message_templates, :platform, :text
  end
end
