class RemoveIndexFromCollectionItems < ActiveRecord::Migration[5.2]
  def change
      remove_index :collection_items, [:channel_id]
      add_index :collection_items, [:channel_id], :unique => false
  end
end
