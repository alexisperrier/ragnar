class Comment < ApplicationRecord
    belongs_to :discussion
    # belongs_to :video,  through: :discussion

end
