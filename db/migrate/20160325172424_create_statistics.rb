class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.string :source
      t.text :data
      t.references :message

      t.timestamps null: false
    end
  end
end
