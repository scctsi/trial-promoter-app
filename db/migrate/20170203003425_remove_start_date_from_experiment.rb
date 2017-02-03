class RemoveStartDateFromExperiment < ActiveRecord::Migration
  def change
    remove_column :experiments, :start_date, :datetime
  end
end
