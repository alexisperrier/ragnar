class Search < ApplicationRecord
  belongs_to :collection
  has_many :collection_items
end
