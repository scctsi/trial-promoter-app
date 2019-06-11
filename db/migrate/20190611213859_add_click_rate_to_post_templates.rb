class AddClickRateToPostTemplates < ActiveRecord::Migration
  def change
    add_column :posts, :click_rate, :float
    add_column :posts, :goal_rate, :float
  end
end
