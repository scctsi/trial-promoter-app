class AddOriginalImageFilenamesToMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :original_image_filenames, :text
  end
end
