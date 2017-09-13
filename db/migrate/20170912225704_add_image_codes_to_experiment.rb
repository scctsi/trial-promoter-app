class AddImageCodesToExperiment < ActiveRecord::Migration
  def change
    add_column :experiments, :image_codes, :string
  end
end
