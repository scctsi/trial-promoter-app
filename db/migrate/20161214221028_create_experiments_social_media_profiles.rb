class CreateExperimentsSocialMediaProfiles < ActiveRecord::Migration
  def change
    create_table :experiments_social_media_profiles do |t|
      t.belongs_to :experiment
      t.belongs_to :social_media_profile
    end
    
    add_index :experiments_social_media_profiles, ['experiment_id', 'social_media_profile_id'], :unique => true, :name => 'index_experiments_social_media_profiles'
  end
end
