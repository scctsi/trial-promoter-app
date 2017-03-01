class CreateClickMeterTrackingLinks < ActiveRecord::Migration
  def change
    create_table :click_meter_tracking_links do |t|
      t.string :click_meter_id
      t.string :click_meter_uri, limit: 2000
      t.string :tracking_url, limit: 2000
      t.string :destination_url, limit: 2000
      t.references :message
      
      t.timestamps null: false
    end
  end
end
