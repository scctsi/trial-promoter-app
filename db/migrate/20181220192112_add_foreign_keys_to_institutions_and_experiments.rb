class AddForeignKeysToInstitutionsAndExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :study_id, :integer
    add_column :institutions, :study_id, :integer
  end
end
