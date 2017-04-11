class AddTextToBufferUpdates < ActiveRecord::Migration
  def change
    add_column :buffer_updates, :published_text, :text
  end
end
