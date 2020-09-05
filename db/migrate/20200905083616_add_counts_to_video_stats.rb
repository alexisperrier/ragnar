class AddCountsToVideoStats < ActiveRecord::Migration[5.2]
  def change
      add_column :video_stat, :like_count, :integer, null: true
      add_column :video_stat, :dislike_count, :integer, null: true
      add_column :video_stat, :favorite_count, :integer, null: true
      add_column :video_stat, :comment_count, :integer, null: true
  end
end
