class AddImagePoolToMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :image_pool, :text
  end
end
