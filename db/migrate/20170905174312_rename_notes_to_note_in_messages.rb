class RenameNotesToNoteInMessages < ActiveRecord::Migration
  def change
    rename_column :messages, :notes, :note
  end
end
