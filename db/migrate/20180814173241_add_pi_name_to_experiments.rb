class AddPiNameToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :pi_first_name, :string
    add_column :experiments, :pi_last_name, :string
  end
end
