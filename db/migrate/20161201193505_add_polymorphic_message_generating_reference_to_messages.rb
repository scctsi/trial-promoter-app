class AddPolymorphicMessageGeneratingReferenceToMessages < ActiveRecord::Migration
  def change
    add_reference :messages, :message_generating, polymorphic: true
    add_index :messages, [:message_generating_type, :message_generating_id], name: 'index_on_message_generating_for_messages'
  end
end
