class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :content
      t.references :experiment
      t.references :post_template

      t.timestamps
    end
  end
end
