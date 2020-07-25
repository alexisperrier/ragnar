class Channel < ApplicationRecord
    self.primary_key = 'channel_id'
    self.table_name = 'channel'
    has_one :pipeline
    has_one :channel_stat
    accepts_nested_attributes_for :pipeline

    # default_scope { order(activity_score: :desc) }
    # default_scope { where("pipeline.status = 'active'") }
    scope :active, -> {  includes(:channel_stat).joins(:pipeline).where("pipeline.status = 'active'").preload(:pipeline)  }

    ACTIVITIES = ["frenetic", "energised", "active", "steady", "sluggish", "asleep", "cold"]
    validates :activity, inclusion: ACTIVITIES
    COUNTRIES =  ["--","FR"] + Channel.select(:country).order(:country).distinct.map{|c| c.country }

    def to_param
      channel_id
    end


    belongs_to :channel

end
