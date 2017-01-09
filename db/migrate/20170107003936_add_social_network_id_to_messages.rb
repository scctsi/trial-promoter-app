class AddSocialNetworkIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :social_network_id, :string
  end
end
