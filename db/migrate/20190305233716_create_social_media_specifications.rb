class CreateSocialMediaSpecifications < ActiveRecord::Migration
  def change
    create_table :social_media_specifications do |t|
      t.string :platform
      t.string :post_type
      t.string :format
      t.string :placement
      t.text :description
      
      t.timestamps
    end
  end
end
