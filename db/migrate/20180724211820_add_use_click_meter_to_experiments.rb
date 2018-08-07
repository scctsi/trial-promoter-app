class AddUseClickMeterToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :use_click_meter, :boolean
  end
end
