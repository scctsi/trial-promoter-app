class ChangeMessagesToUsePolymorphicAssociationToAPromotableObject < ActiveRecord::Migration
  def change
    add_reference :messages, :promotable, polymorphic: true
    remove_column :messages, :clinical_trial_id
    add_index :messages, [:promotable_type, :promotable_id], name: 'index_on_promotable_for_messages'
  end
end