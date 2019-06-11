class CreateSplitTests < ActiveRecord::Migration
  def change
    create_table :split_tests do |t|
      t.references :experiment
      t.integer :variation_a_id
      t.integer :variation_b_id

      t.timestamps null: false
    end
  end
end
