class AddIndexComments < ActiveRecord::Migration[5.2]
  def change
      add_index :comments, [:comment_id], :unique => true
  end
end
