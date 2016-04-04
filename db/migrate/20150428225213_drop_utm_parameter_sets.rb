class DropUtmParameterSets < ActiveRecord::Migration
  def change
    drop_table :utm_parameter_sets
  end
end
