class CreateLists < ActiveRecord::Migration[5.2]
  def change
    create_table :lists do |t|
      t.string :title
      t.text :description
      t.references :user
      t.timestamps
    end
  end
end
