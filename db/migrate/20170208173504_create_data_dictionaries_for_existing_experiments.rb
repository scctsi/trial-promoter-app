class CreateDataDictionariesForExistingExperiments < ActiveRecord::Migration
  def up
    Experiment.all.each do |experiment|
      DataDictionary.create_data_dictionary(experiment)
    end
  end
  
  def down
    Experiment.all.each do |experiment|
      experiment.data_dictionary.destroy
    end
  end
end
