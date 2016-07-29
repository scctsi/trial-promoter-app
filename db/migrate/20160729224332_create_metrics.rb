class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :source
      t.text :data
      t.references :message

      t.timestamps null: false
    end
  end
end