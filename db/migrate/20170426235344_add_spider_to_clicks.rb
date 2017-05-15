class AddSpiderToClicks < ActiveRecord::Migration
  def change
    add_column :clicks, :spider, :boolean
  end
end
