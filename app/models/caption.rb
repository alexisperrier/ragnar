class Caption < ApplicationRecord
    self.table_name = 'caption'
    belongs_to :video
end
