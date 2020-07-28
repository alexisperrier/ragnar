class Category < ApplicationRecord
    self.table_name = 'yt_categories'
    self.primary_key = 'category_id'
    has_many :video
end
