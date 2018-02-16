class AddMessageRunDurationInDaysToMessageGenerationParameterSet < ActiveRecord::Migration
  def change
    add_column :message_generation_parameter_sets, :message_run_duration_in_days, :integer
  end
end
