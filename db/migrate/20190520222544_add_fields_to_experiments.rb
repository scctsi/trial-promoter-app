class AddFieldsToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :official_title, :string, :limit => 1000
    add_column :experiments, :recruitment_period, :string
    add_column :experiments, :channels, :string
    add_column :experiments, :target_audience, :string
    add_column :experiments, :budget, :string
    add_column :experiments, :accrual_target, :string
  end
end
