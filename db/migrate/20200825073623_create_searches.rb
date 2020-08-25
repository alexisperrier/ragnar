class CreateSearches < ActiveRecord::Migration[5.2]
  def change
    create_table :searches do |t|
      t.string :query
      t.references :user, foreign_key: true
      t.references :collection, foreign_key: true
      t.string :keywords
      t.string :on
      t.timestamps
    end
  end
end
