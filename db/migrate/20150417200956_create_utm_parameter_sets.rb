class CreateUtmParameterSets < ActiveRecord::Migration
  def change
    create_table :utm_parameter_sets do |t|
      t.string :source
      t.string :medium
      t.string :term
      t.string :content
      t.string :campaign

      t.timestamps null: false
    end
  end
end
