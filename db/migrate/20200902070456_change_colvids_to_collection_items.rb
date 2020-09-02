class ChangeColvidsToCollectionItems < ActiveRecord::Migration[5.2]
  def change
      rename_table :colvids, :collection_items      
  end
end
