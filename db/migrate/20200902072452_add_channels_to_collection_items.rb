class AddChannelsToCollectionItems < ActiveRecord::Migration[5.2]
  def change
      add_column :collection_items, :channel_id, :string, null: true
      # add_reference :collection_items, :channel, index: true, foreign_key: False, null: true
      add_index :collection_items, [:channel_id], :unique => true
      add_index :collection_items, [:channel_id,:collection_id], :unique => true
  end
end
