class ChangePublishedAtToScheduledAtInMessages < ActiveRecord::Migration
  def change
    rename_column :messages, :published_at, :scheduled_at
  end
end
