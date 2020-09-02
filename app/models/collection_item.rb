class CollectionItem < ApplicationRecord
  belongs_to :collection
  belongs_to :video, optional: true
  belongs_to :channel, optional: true
  belongs_to :search, optional: true
end
