class AddOriginToCollectionItems < ActiveRecord::Migration[5.2]
  def change
      add_column :collection_items, :origin, :string, null: true
  end
end
