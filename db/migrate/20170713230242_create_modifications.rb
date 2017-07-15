class CreateModifications < ActiveRecord::Migration
  def change
    create_table :modifications do |t|
      t.references :experiment
      t.string :description
      t.text :details

      t.timestamps null: false
    end
  end
end
