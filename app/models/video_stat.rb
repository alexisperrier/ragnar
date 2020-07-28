class VideoStat < ApplicationRecord
    self.table_name = 'video_stat'
    belongs_to :video
end
