class CreateExports < ActiveRecord::Migration[5.2]
  def change
    create_table :exports do |t|
        t.string :collection_id
        t.string :title
        t.string :description
        t.timestamps
    end
    add_index :exports, [:collection_id], :unique => false
  end
end
