class AddScheduledDateAndScheduledTimeFieldsToMessages < ActiveRecord::Migration
  def change
    rename_column :messages, :social_network_publish_date, :scheduled_date_time
  end
end
