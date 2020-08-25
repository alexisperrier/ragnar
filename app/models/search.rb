class Search < ApplicationRecord
  belongs_to :collection
  has_many :colvids
end
