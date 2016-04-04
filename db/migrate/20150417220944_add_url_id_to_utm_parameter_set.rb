class AddUrlIdToUtmParameterSet < ActiveRecord::Migration
  def change
    add_column :utm_parameter_sets, :url_id, :integer
  end
end
