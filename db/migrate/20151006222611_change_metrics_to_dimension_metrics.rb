class ChangeMetricsToDimensionMetrics < ActiveRecord::Migration
  def self.up
    rename_table :metrics, :dimension_metrics
  end
  def self.down
    rename_table :dimension_metrics, :metrics
  end
end