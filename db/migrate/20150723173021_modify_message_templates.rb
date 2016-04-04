class ModifyMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :initial_id, :string
    add_column :message_templates, :platform, :string
    add_column :message_templates, :message_type, :string
    remove_column :message_templates, :platform_id
  end
end