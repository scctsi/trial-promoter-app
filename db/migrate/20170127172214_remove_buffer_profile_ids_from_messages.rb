class RemoveBufferProfileIdsFromMessages < ActiveRecord::Migration
  def up
    remove_column :messages, :buffer_profile_ids
  end
  
  def down
    add_column :messages, :buffer_profile_ids, :string
  end
end
