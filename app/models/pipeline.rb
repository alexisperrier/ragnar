class Pipeline < ApplicationRecord
    self.table_name = 'pipeline'
    belongs_to :channel, foreign_key: 'channel_id'

    CHANNEL_STATUS  = ["--","incomplete", "active", "foreign", "unavailable", "feed_empty", "feed_error"]
    VIDEO_STATUS    = ["incomplete", "active",  "cold", "unavailable"]

end
