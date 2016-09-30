class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.string :title, limit: 1000
      t.string :url, limit: 2000

      t.timestamps null: false
    end
  end
end
