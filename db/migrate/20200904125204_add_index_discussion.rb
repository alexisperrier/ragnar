class AddIndexDiscussion < ActiveRecord::Migration[5.2]
  def change
      remove_index :discussions, [:video_id]
      add_index :discussions, [:video_id], :unique => true
  end
end
