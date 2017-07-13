class CreateImageReplacementActions < ActiveRecord::Migration
  def change
    create_table :image_replacement_actions do |t|
      t.text :replacements
      
      t.timestamps null: false
    end
  end
end
