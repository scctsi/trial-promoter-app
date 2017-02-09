class ChangeTrialPromoterLabelToLabel < ActiveRecord::Migration
  def change
    rename_column :data_dictionary_entries, :trial_promoter_label, :label
  end
end
