class AddWebsiteGoalCountToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :website_goal_count, :integer
  end
end
