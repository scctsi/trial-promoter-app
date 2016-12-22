class BufferPublishDateToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :buffer_publish_date, :datetime
  end
end
