class CreateSocialMediaSpecifications < ActiveRecord::Migration
  def change
    create_table :social_media_specifications do |t|
      t.string :platform
      t.string :post_type
      t.string :format
      t.string :placement
      t.text :description
<<<<<<< HEAD
      
      t.timestamps
=======
>>>>>>> 9c74c1f9566183b932fe0740bae0085ed3e5485e
    end
  end
end
