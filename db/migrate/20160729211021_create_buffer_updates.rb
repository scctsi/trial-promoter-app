class CreateBufferUpdates < ActiveRecord::Migration
  def change
    create_table :buffer_updates do |t|
      t.string :buffer_id
      t.string :service_update_id
      t.string :status
      t.references :message

      t.timestamps null: false
    end
  end
end