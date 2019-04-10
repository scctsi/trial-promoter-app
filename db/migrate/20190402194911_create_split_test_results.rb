class CreateSplitTestResults < ActiveRecord::Migration
  def change
    create_table :split_test_results do |t|
      t.references :split_test
      t.integer :winning_variation_id
      t.integer :losing_variation_id
      t.datetime :stop_time
      
      t.timestamps null: false
    end
  end
end
