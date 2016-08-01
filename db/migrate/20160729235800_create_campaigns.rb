class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name, limit: 1000
      t.datetime :start_date
      t.datetime :end_date
      
      t.timestamps null: false
    end
  end
end
