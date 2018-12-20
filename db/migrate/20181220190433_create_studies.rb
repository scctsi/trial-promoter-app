class CreateStudies < ActiveRecord::Migration
  def change
    create_table :studies do |t|
      t.belongs_to :experiment, index: true
      t.belongs_to :institution, index: true
    end
  end
end
