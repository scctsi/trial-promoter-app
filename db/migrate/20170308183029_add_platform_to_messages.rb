class AddPlatformToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :platform, :string
  end
end
