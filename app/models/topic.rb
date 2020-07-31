class Topic < ApplicationRecord
    self.table_name = 'topic'
    belongs_to :channel
end
