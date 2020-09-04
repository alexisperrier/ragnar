class CreateComments < ActiveRecord::Migration[5.2]
    def change
        create_table :comments do |t|
            t.string :comment_id
            t.string :video_id
            t.string :discussion_id
            t.string :parent_id
            t.string :author_name
            t.string :author_channel_id
            t.string :text
            t.integer :reply_count
            t.integer :like_count
            t.datetime :published_at

            t.timestamps
        end
        add_index :comments, [:video_id], :unique => false
        add_index :comments, [:discussion_id], :unique => false
    end
end
