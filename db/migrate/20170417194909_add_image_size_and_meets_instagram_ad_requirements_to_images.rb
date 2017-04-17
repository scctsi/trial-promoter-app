class AddImageSizeAndMeetsInstagramAdRequirementsToImages < ActiveRecord::Migration
  def change
    add_column :images, :width, :integer
    add_column :images, :height, :integer
    add_column :images, :meets_instagram_ad_requirements, :boolean
  end
end
