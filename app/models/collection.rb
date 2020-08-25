class Collection < ApplicationRecord
    belongs_to :user
    has_many :colvids
    has_many :videos, through: :colvids
end
