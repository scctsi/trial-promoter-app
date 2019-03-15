class CreatePostTemplates < ActiveRecord::Migration
  def change
    create_table :post_templates do |t|
      t.text :content
      t.text :image_pool
      t.references :social_media_specification
      t.references :experiment
      
      t.timestamps
    end
  end
end
