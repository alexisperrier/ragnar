class Channel < ApplicationRecord
    require 'csv'
    self.primary_key = 'channel_id'
    self.table_name = 'channel'
    has_one :pipeline
    accepts_nested_attributes_for :pipeline
    has_one :channel_stat
    has_many :video

    scope :active, -> {  includes(:channel_stat).joins(:pipeline).where("pipeline.status = 'active'").preload(:pipeline)  }

    ACTIVITIES = ["frenetic", "energised", "active", "steady", "sluggish", "asleep", "cold"]
    validates :activity, inclusion: ACTIVITIES
    COUNTRIES =  ["--","FR"] + Channel.select(:country).order(:country).distinct.map{|c| c.country }

    def to_param
      channel_id
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

    belongs_to :channel

end
