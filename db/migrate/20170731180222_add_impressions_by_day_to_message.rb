class AddImpressionsByDayToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :impressions_by_day, :text
  end
end
