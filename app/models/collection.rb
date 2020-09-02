class Collection < ApplicationRecord
    belongs_to :user
    has_many :collection_items
    has_many :videos, through: :collection_items
    has_many :channels, through: :collection_items
end
