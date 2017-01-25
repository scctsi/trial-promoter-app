class AddAnalyticsFileToDosCreatedToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :analytics_file_todos_created, :boolean
  end
end
