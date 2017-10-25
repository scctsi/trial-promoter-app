class ChangeMessageIdTypeInComments < ActiveRecord::Migration
  def self.up
    change_column :comments, :message_id, :string
  end
 
  def self.down
    change_column :comments, :message_id, :integer
  end
end
