class AddPlatformIdToMessageTemplate < ActiveRecord::Migration
  def change
    add_column :message_templates, :platform_id, :integer
  end
end
