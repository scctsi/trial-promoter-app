class AddToxicityScoreToComments < ActiveRecord::Migration
  def change
    add_column :comments, :toxicity_score, :string
  end
end
