class Video < ApplicationRecord
    require 'csv'
    self.primary_key    = 'video_id'
    self.table_name     = 'video'
    belongs_to  :channel
    belongs_to  :category
    has_one     :pipeline
    has_many    :video_stat
    has_one     :caption
    accepts_nested_attributes_for :pipeline

    scope :recent, -> { where("published_at > ?", 1.day.ago).preload(:pipeline, :channel)}
    scope :active, -> { joins(:pipeline).where("pipeline.status = 'active'")  }

    def self.most_viewed
        sql = "
        select v.video_id, max(vs.views) as maxviews
        from video v
        join video_stat vs on vs.video_id = v.video_id
        where v.published_at > NOW() - interval '24 hours'
        group by v.video_id
        order by maxviews desc
        limit 10;
        "
        vids = ActiveRecord::Base.connection.execute(sql).map{|v|v['video_id']}
        Video.where(video_id: vids)
    end


    def to_param
      video_id
    end

    def maxviews
        if self.video_stat.any?
            self.video_stat.order(:viewed_at).last().views
        end
    end

end
