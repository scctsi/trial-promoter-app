class ConvertJsonToJsonbInAhoyEvents < ActiveRecord::Migration
  def up
    change_column :ahoy_events, :properties, :jsonb
  end

  def down
    change_column :ahoy_events, :properties, :json
  end
end
