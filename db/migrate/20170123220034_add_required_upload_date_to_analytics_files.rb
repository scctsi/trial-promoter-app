class AddRequiredUploadDateToAnalyticsFiles < ActiveRecord::Migration
  def change
    add_column :analytics_files, :required_upload_date, :datetime
  end
end
