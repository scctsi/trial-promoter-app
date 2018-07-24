class AddNumberOfDaysBetweenPosting < ActiveRecord::Migration
  def change
    add_column :message_generation_parameter_sets, :number_of_days_between_posting, :integer, :default => 1
  end
end
