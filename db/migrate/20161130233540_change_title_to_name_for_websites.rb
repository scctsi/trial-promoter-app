class ChangeTitleToNameForWebsites < ActiveRecord::Migration
  def change
    rename_column :websites, :title, :name
  end
end
