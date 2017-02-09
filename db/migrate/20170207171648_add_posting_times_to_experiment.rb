class AddPostingTimesToExperiment < ActiveRecord::Migration
  def change
    add_column :experiments, :posting_times, :text
  end
end
