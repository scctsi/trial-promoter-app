class AddRoleToUsers < ActiveRecord::Migration
  def up
    add_column :users, :role, :string, default: 'user'

    change_column_null :users, :role, false
  end

  def down
    remove_column :users, :role, :string
  end
end
