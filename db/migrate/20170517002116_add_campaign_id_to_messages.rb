class AddCampaignIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :campaign_id, :string
  end
end
