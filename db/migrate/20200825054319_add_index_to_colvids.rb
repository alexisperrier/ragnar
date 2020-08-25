class AddIndexToColvids < ActiveRecord::Migration[5.2]
  def change
      add_index :colvids, [:video_id,:collection_id], :unique => true
  end
end
