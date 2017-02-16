class ConvertJsonToJsonbInAhoyEvents < ActiveRecord::Migration
  def up
    remove_column :ahoy_events, :properties, :json
    add_column :ahoy_events, :properties, :jsonb
  end

  def down
    remove_column :ahoy_events, :properties, :jsonb
    add_column :ahoy_events, :properties, :json
  end
end
