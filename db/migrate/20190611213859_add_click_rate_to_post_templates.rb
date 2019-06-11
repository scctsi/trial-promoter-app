class AddClickRateToPostTemplates < ActiveRecord::Migration
  def change
    add_column :post_templates, :click_rate, :float
    add_column :post_templates, :goal_rate, :float
  end
end
