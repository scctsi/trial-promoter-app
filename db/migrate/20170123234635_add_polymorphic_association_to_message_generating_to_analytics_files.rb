class AddPolymorphicAssociationToMessageGeneratingToAnalyticsFiles < ActiveRecord::Migration
  def change
    add_reference :analytics_files, :message_generating, polymorphic: true
    add_index :messages, [:message_generating_type, :message_generating_id], name: 'index_on_message_generating_for_analytics_files'
  end
end
