class Recommendation < ApplicationRecord
    self.table_name = 'video_recommendations'
    belongs_to :video

    def self.most_recommended
        Recommendation.where("tgt_video_harvested_at > ?", 24.hour.ago).select(:tgt_video_id).group(:tgt_video_id).count.sort_by {|k, v| -v}.first(20).to_h
    end


    def self.upstream_counts(videos)
        # Recommendation.where(tgt_video_id: vids ).group(:tgt_video_id).count

        self.preload(:video).where(tgt_video_id: videos).group(:tgt_video_id).count
    end

end
