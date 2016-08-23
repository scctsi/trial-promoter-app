class CreateHashtags < ActiveRecord::Migration
  def change
    create_table :hashtags do |t|
      t.string :phrase
      
      t.timestamps null: false
    end
  end
end
