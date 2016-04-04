class CreateDimensionMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.text :dimensions
      t.text :metrics

      t.timestamps
    end
  end
end