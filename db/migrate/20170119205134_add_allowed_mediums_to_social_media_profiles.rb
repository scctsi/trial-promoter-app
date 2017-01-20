class AddAllowedMediumsToSocialMediaProfiles < ActiveRecord::Migration
  def change
    add_column :social_media_profiles, :allowed_mediums, :string
  end
end
