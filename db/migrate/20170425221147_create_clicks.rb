class CreateClicks < ActiveRecord::Migration
  def change
    create_table :clicks do |t|
      t.datetime :click_time

      t.timestamps null: false
    end
  end
end
