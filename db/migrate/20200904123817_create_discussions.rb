class CreateDiscussions < ActiveRecord::Migration[5.2]
    def change
        create_table :discussions do |t|
            t.string :video_id
            t.integer :total_results
            t.integer :results_per_page
            t.string :error, null: true
            t.timestamps
        end
        add_index :discussions, [:video_id], :unique => false
    end
end
