class AddPerPlatformPostingTimes < ActiveRecord::Migration
  def change
    add_column :experiments, :twitter_posting_times, :text
    add_column :experiments, :facebook_posting_times, :text
    add_column :experiments, :instagram_posting_times, :text
    remove_column :experiments, :posting_times, :text
  end
end
