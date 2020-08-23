class Video < ApplicationRecord
    require 'csv'
    self.primary_key    = 'video_id'
    self.table_name     = 'video'
    belongs_to  :channel
    belongs_to  :category
    belongs_to  :collection
    has_one     :pipeline
    has_one     :augment
    has_many    :video_stat
    has_many    :recommendations, foreign_key: 'tgt_video_id'
    has_one     :caption
    accepts_nested_attributes_for :pipeline

    attr_accessor :upstream_count, :downstream_count

    scope :recent, -> { where("published_at > ?", 1.day.ago).preload(:pipeline, :channel)}
    scope :active, -> { joins(:pipeline).where("pipeline.status = 'active'")  }


    def upstream_channels
        sql = "select count(*) as n, v.channel_id
                from video v
                where v.video_id in (
                    select src_video_id from video_recommendations
                    where tgt_video_id = '#{id}'
                )
                group by v.channel_id
                order by n desc limit 20
                ;
            "
        channels = ActiveRecord::Base.connection.execute(sql).map{|v| [  v['channel_id'], v['n'] ]  }.to_h
    end

    def downstream_channels
        sql = "select count(*) as n, v.channel_id
                from video v
                where v.video_id in (
                    select tgt_video_id from video_recommendations
                    where src_video_id = '#{id}'
                )
                group by v.channel_id
                order by n desc limit 20
                ;
            "
        channels = ActiveRecord::Base.connection.execute(sql).map{|v| [  v['channel_id'], v['n'] ]  }.to_h
    end

    def self.most_viewed
        sql = "
            select v.video_id, max(vs.views) as maxviews
            from video v
            join video_stat vs on vs.video_id = v.video_id
            where vs.viewed_at > '#{2.days.ago.to_date.strftime("%Y-%m-%d")}'
            and v.published_at > NOW() - interval '24 hours'
            group by v.video_id
            order by maxviews desc
            limit 20;
        "
        vids = ActiveRecord::Base.connection.execute(sql).map{|v|v['video_id']}
        Video.where(video_id: vids).preload(:pipeline, :channel, :category)
    end

    def to_param
      video_id
    end

    def recent_recos
        if self.recommendations.any?
            self.recommendations.where("tgt_video_harvested_at > ?", 24.hour.ago).count
        end
    end

    def maxviews
        if self.video_stat.any?
            self.video_stat.order(:viewed_at).last().views
        end
    end

end
