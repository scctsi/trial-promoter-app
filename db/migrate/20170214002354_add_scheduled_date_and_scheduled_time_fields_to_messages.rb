class AddScheduledDateAndScheduledTimeFieldsToMessages < ActiveRecord::Migration
  def change
    rename_column :messages, :social_network_publish_date, :scheduled_date
    add_column :messages, :scheduled_time, :datetime
  end
end
