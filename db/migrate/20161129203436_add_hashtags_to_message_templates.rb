class AddHashtagsToMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :hashtags, :text
  end
end
