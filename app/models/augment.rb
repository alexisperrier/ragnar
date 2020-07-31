class Augment < ApplicationRecord
    self.table_name = 'augment'
    belongs_to :video

end
