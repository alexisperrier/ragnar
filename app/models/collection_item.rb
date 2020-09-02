class CollectionItem < ApplicationRecord
  belongs_to :collection
  belongs_to :video
  belongs_to :search
end
