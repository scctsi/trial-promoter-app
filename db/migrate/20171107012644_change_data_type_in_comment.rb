class ChangeDataTypeInComment < ActiveRecord::Migration
  def change
    change_column :comments, :comment_date, :datetime
  end
end
