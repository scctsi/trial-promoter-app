class AddClickMeterTrackingLinkToClicks < ActiveRecord::Migration
  def change
    add_reference :clicks, :click_meter_tracking_link, index: true, foreign_key: true
  end
end
