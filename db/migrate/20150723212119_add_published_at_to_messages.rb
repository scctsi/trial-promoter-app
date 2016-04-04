class AddPublishedAtToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :published_at, :datetime
  end
end
