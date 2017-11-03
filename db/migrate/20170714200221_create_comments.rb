class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|

      t.date :message_date
      t.text :message
      t.date :comment_date
      t.text :comment_text
      t.text :commentator_username

      t.timestamps null: false
    end
  end
<<<<<<< HEAD
end
=======
end
>>>>>>> development
