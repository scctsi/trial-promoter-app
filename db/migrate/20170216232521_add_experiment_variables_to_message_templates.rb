class AddExperimentVariablesToMessageTemplates < ActiveRecord::Migration
  def change
    add_column :message_templates, :experiment_variables, :text 
  end
end
