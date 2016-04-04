class AddServiceStatisticsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :service_statistics, :text
  end
end
