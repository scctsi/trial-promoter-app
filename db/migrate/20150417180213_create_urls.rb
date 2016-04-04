class CreateUrls < ActiveRecord::Migration
  def change
    create_table :urls do |t|
      t.string :value, limit: 2000

      t.timestamps null: false
    end
  end
end
