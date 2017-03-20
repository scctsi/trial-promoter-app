class AddClickMeterDomainIdAndGroupIdToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :click_meter_group_id, :integer
    add_column :experiments, :click_meter_domain_id, :integer
  end
end
