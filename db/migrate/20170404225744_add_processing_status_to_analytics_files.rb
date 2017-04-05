class AddProcessingStatusToAnalyticsFiles < ActiveRecord::Migration
  def change
    add_column :analytics_files, :processing_status, :string
  end
end
