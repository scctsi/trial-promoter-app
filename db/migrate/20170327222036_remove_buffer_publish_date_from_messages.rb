class RemoveBufferPublishDateFromMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :buffer_publish_date, :datetime
  end
end
