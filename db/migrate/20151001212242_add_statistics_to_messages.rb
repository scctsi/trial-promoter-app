class AddStatisticsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :statistics, :text
  end
end
