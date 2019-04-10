class AddPostIdToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :post_id, :integer
  end
end
