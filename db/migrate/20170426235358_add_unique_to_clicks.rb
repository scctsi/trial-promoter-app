class AddUniqueToClicks < ActiveRecord::Migration
  def change
    add_column :clicks, :unique, :boolean
  end
end
