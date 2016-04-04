class AddServiceUpdateIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :service_update_id, :string
  end
end
