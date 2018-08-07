class CreateExperimentsUsers < ActiveRecord::Migration
  def change
    create_table :experiments_users, id: false do |t|
      t.belongs_to :experiment, index: true
      t.belongs_to :user, index: true
    end
  end
end
