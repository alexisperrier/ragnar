class Channel < ApplicationRecord
    require 'csv'
    self.primary_key = 'channel_id'
    self.table_name = 'channel'
    has_one :pipeline
    accepts_nested_attributes_for :pipeline
    has_one  :channel_stat
    has_one  :topic
    has_many :video
    has_many :video_stat, through: :video
    has_many :related_channel
    has_many    :collection_items
    has_many    :collections, through: :collection_items
    belongs_to  :collection, optional: true
    
    scope :active, -> {  includes(:channel_stat).joins(:pipeline).where("pipeline.status = 'active'").where(country: "FR").preload(:pipeline)  }

    ACTIVITIES = ["frenetic", "energised", "active", "steady", "sluggish", "asleep", "cold"]
    validates :activity, inclusion: ACTIVITIES
    COUNTRIES =   Channel.select(:country).order(:country).distinct.map{|c| c.country } - ["",nil, "FR"]
    COUNTRIES =  ["All","FR","not FR","Null"] + COUNTRIES

    def to_param
      channel_id
    end

    def related_channel_ids
        RelatedChannel.where(channel_id: id).select(:related_id).map{|r| r.related_id}
    end

    def related_channels
        channels = []
        related_channel_ids.each do |id|
            if Channel.exists?(id)
                channels.append(Channel.find(id))
            else
                channels.append(id)
            end
        end
        channels
    end

    def upstream
        sql = "
            select count(*) as n, cha.channel_id, cha.title
            from video_recommendations vr
            join video vi on vi.video_id = vr.src_video_id
            join channel cha on vi.channel_id = cha.channel_id
            where tgt_video_id in (
                select v.video_id
                from channel as ch
                join video v on v.channel_id = ch.channel_id
                where ch.channel_id = '#{id}'
            )
            group by cha.channel_id, cha.title
            order by n desc limit 20
        "
        ActiveRecord::Base.connection.execute(sql).map{|v| [  v['channel_id'], v['n'] ]  }.to_h
    end

    def downstream
        sql = "
                select count(*) as n, cha.channel_id
                from video_recommendations vr
                join video vi on vi.video_id = vr.tgt_video_id
                join channel cha on vi.channel_id = cha.channel_id
                where src_video_id in (
                    select v.video_id
                    from channel as ch
                    join video v on v.channel_id = ch.channel_id
                    where ch.channel_id = '#{id}'
                )
                group by cha.channel_id, cha.title
                order by n desc limit 20
            "
        ActiveRecord::Base.connection.execute(sql).map{|v| [  v['channel_id'], v['n'] ]  }.to_h
    end

    def self.to_csv
        channel_attributes  = %w{channel_id title country activity activity_score
                description created_at retrieved_at}
        pipeline_attributes = %w{ status lang}
        stat_attributes     = %w{ views subscribers videos}

        CSV.generate(headers: true) do |csv|
          csv << channel_attributes + pipeline_attributes + stat_attributes
          all.each do |channel|
              channel_row =  channel_attributes.map{ |attr| channel.send(attr) }
              if channel.pipeline
                  pipeline_row = pipeline_attributes.map{ |attr| channel.pipeline.send(attr) }
              else
                  pipeline_row = pipeline_attributes.map{ '' }
              end
              if channel.channel_stat
                  stat_row = stat_attributes.map{ |attr| channel.channel_stat.send(attr) }
              else
                  stat_row = stat_attributes.map{ '' }
              end

            csv << channel_row + pipeline_row + stat_row
          end
        end
     end

    # belongs_to :channel

end
