class AddTrackingUrlCampaignAndMediumToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :tracking_url, :string, :limit => 2000
    add_column :messages, :campaign, :string
    add_column :messages, :medium, :string
  end
end
