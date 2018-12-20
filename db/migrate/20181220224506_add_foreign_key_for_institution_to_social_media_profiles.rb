class AddForeignKeyForInstitutionToSocialMediaProfiles < ActiveRecord::Migration
  def change
    add_column :social_media_profiles, :institution_id, :integer
  end
end
