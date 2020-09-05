class Discussion < ApplicationRecord
    belongs_to :video
    has_many :comments
end
