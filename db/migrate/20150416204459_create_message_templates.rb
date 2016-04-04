class CreateMessageTemplates < ActiveRecord::Migration
  def change
    create_table :message_templates do |t|
      t.text :content

      t.timestamps null: false
    end
  end
end
