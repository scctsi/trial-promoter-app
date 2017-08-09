class AddWebsiteSessionCountToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :website_session_count, :integer
  end
end
