class ChangeFormatOfCodesInExperiment < ActiveRecord::Migration
  def change
    change_column :experiments, :image_codes, :text
    change_column :experiments, :comment_codes, :text
  end
end
