class AddCampaignUnmatchableToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :campaign_unmatchable, :boolean, :default => false
  end
end
