class AddWebsiteGoalRateToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :website_goal_rate, :float
  end
end
