class AddBufferUpdateIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :buffer_update_id, :string
  end
end
