class ChannelSearch
    include ActiveModel::Model

    attr_accessor :status, :country, :sort_by, :sort_asc
    def to_s
        "Status: #{self.status} Country #{self.country} Sort: #{self.sort_by} #{self.sort_asc}"
    end
end
