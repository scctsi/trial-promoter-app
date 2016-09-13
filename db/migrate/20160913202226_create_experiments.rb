class CreateExperiments < ActiveRecord::Migration
  def change
    create_table :experiments do |t|
      t.string :name, limit: 1000
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :message_distribution_start_date

      t.timestamps null: false
    end
  end
end