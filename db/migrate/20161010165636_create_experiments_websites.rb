class CreateExperimentsWebsites < ActiveRecord::Migration
  def change
    create_table :experiments_websites do |t|
      t.belongs_to :experiment, index: true
      t.belongs_to :website, index: true
    end
  end
end
