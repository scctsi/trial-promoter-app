class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.string :name
      t.string :category
      t.string :zip_code
      
      t.timestamps
    end
  end
end
