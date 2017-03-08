class AddPlatformsToMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :platforms, :text
  end
end
