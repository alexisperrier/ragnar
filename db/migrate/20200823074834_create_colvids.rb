class CreateColvids < ActiveRecord::Migration[5.2]
  def change
    create_table :colvids do |t|
      t.references :collection, foreign_key: true
      t.string "video_id", limit: 11

      t.timestamps
    end
  end
end
