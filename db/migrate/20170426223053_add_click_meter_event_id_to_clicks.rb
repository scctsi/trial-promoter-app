class AddClickMeterEventIdToClicks < ActiveRecord::Migration
  def change
    add_column :clicks, :click_meter_event_id, :string
  end
end
