class AddBackdateFieldsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :backdated, :boolean
    add_column :messages, :original_scheduled_date_time, :datetime
  end
end
