class AddDefaultBooleanInExperiments < ActiveRecord::Migration
  def change
    change_column :experiments, :use_click_meter, :boolean, default: false
  end
end
