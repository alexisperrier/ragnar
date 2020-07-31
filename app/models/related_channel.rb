class RelatedChannel < ApplicationRecord
    self.table_name = 'related_channels'
    self.primary_key = 'channel_id'
    belongs_to :channel
end
