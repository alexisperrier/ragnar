class CreateExportItems < ActiveRecord::Migration[5.2]
  def change
    create_table :export_items do |t|
        t.string :export_id
        t.string :title
        t.integer :filesize
        t.integer :nrows
        t.integer :ncolumns

        t.timestamps
    end
    add_index :export_items, [:export_id], :unique => false
  end
end
