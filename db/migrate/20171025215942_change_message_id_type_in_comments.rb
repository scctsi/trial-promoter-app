class ChangeMessageIdTypeInComments < ActiveRecord::Migration
  def self.up
    remove_column :comments, :message_id
    add_column :comments, :message_id, :integer
  end
 
  def self.down
    remove_column :comments, :message_id
    add_column :comments, :message_id, :string
  end
end
