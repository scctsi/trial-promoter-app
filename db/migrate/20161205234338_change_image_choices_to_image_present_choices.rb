class ChangeImageChoicesToImagePresentChoices < ActiveRecord::Migration
  def change
    rename_column :message_generation_parameter_sets, :image_choices, :image_present_choices
  end
end
