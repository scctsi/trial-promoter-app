class AddProcessingStatusToAnalyticsFiles < ActiveRecord::Migration
  def change
    add :analytics_files, :processing_status, :string
  end
end
