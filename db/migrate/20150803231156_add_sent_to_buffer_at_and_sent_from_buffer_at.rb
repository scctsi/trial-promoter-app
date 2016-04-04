class AddSentToBufferAtAndSentFromBufferAt < ActiveRecord::Migration
  def change
    add_column :messages, :sent_to_buffer_at, :datetime
    add_column :messages, :sent_from_buffer_at, :datetime
  end
end
