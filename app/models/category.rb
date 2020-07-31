class Category < ApplicationRecord
    self.table_name = 'yt_categories'
    self.primary_key = 'category_id'
    has_many :video

    CAT_SELECT = Category.where(assignable: 'true').select(:category_id, :category).order(:category).map{|c| [c.category,c.category_id]  }.append(["All",0]).sort_by {|_key, value| value}.to_h
end
