class Export < ApplicationRecord
    require 'digest/sha1'
    require 'csv'
    belongs_to :collection
    has_many :export_items

    def self.to_csv(df)
        filename = "#{Rails.root.to_s}/tmp/tmp_#{Digest::SHA1.hexdigest(Time.now.strftime('%Y%m%d%H%M%S'))}.csv"
        writer = CSV.open(filename, 'w')
        writer << df.vectors.to_a
        # remove commas
        df.each_row do |row|
          writer << row.map { |v| v.to_s.tr(',', '').gsub(/\s+/, " ") }
        end
        writer.close
        return filename
    end

end
