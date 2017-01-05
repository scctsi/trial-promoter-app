class ChangeStatusToPublishStatusInMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :status, :string
    add_column :messages, :publish_status, :string
  end
end
