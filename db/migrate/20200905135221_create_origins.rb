class CreateOrigins < ActiveRecord::Migration[5.2]
  def change
    create_table :origins do |t|
        t.string :channel_id
        t.string :video_id
        t.string :filename
        t.string :title
        t.string :description
        t.timestamps
    end
  end
end
