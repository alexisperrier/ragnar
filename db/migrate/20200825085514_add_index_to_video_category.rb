class AddIndexToVideoCategory < ActiveRecord::Migration[5.2]
  def change
      add_index :video, :category_id
  end
end
