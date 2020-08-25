class VideoSearch
    include ActiveModel::Model

    attr_accessor :status, :keyword, :pubdate, :category_id, :sort_by, :sort_asc
    
    def to_s
        "Pubdate: #{self.pubdate} Category: #{self.category_id} Status: #{self.status} KW #{self.keyword} Sort: #{self.sort_by} #{self.sort_asc}"
    end
end
