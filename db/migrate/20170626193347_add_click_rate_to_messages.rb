class AddClickRateToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :click_rate, :float
  end
end
