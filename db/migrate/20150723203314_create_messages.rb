class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :content
      t.references :clinical_trial
      t.references :message_template

      t.timestamps
    end
  end
end
