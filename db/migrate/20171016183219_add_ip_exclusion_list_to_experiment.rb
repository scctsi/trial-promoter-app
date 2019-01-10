class AddIpExclusionListToExperiment < ActiveRecord::Migration
  def change
    add_column :experiments, :ip_exclusion_list, :text
  end
end
