class AddAnalyticsFileSetIdToAnalyticsFiles < ActiveRecord::Migration
  def change
    add_column :analytics_files, :analytics_file_set_id, :integer
  end
end
