class ChannelStat < ApplicationRecord
    self.table_name = 'channel_stat'
    belongs_to :channel, foreign_key: 'channel_id'
end
