class VideoStat < ApplicationRecord
    self.table_name = 'video_stat'
    belongs_to :video

    def self.maxviews(videos)
        self.preload(:video).where(video_id: videos).group(:video_id).maximum(:views)
    end

end
