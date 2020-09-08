class ExportItem < ApplicationRecord
    belongs_to :export
    has_one_attached :csvfile
end
