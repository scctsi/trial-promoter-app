class CreateImageReplacements < ActiveRecord::Migration
  def change
    create_table :image_replacements do |t|
      t.references :message
      t.references :previous_image
      t.references :replacement_image
      
      t.timestamps null: false
    end
  end
end
