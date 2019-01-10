class AddAdPublishedToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :ad_published, :boolean
  end
end
