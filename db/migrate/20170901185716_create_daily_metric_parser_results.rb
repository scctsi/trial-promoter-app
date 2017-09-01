class CreateDailyMetricParserResults < ActiveRecord::Migration
  def change
    create_table :daily_metric_parser_results do |t|
      t.date :file_date
      t.text :file_path
      t.text :parsed_data

      t.timestamps null: false
    end
  end
end
