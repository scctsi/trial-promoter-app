class AddCommentCodesToExperiment < ActiveRecord::Migration
  def change
    add_column :experiments, :comment_codes, :string
  end
end
