class CreateAnalyticsFileSets < ActiveRecord::Migration
  def change
    create_table :analytics_file_sets do |t|
      t.timestamps null: false
    end
  end
end
