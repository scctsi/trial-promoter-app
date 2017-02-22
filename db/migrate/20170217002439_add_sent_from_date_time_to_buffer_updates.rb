class AddSentFromDateTimeToBufferUpdates < ActiveRecord::Migration
  def change
    add_column :buffer_updates, :sent_from_date_time, :datetime
  end
end
