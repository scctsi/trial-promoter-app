class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :url, limit: 2000
      t.string :original_filename

      t.timestamps null: false
    end
  end
end
