class RemoveAnalyticsFileToDosCreatedOnExperiments < ActiveRecord::Migration
  def change
    remove_column :experiments, :analytics_file_todos_created, :boolean
  end
end
