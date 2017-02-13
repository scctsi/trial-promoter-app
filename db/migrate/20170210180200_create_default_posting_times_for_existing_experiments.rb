class CreateDefaultPostingTimesForExistingExperiments < ActiveRecord::Migration
  def up
    Experiment.all.each do |experiment|
      experiment.posting_times = ('12:00 AM,' * experiment.message_generation_parameter_set.number_of_messages_per_social_network).chomp(',')
      experiment.save
    end
  end

  def down
    Experiment.all.each do |experiment|
      experiment.postring_times = nil
      experiment.save
    end
  end
end