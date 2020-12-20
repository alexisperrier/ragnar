'''
export = Export.create({ collection_id: @collection.id, title: @collection.title })
'''
require 'tqdm'
require 'optparse'

ARGV.shift
ARGV.shift

def params()
    options = {}
    OptionParser.new do |opts|
        opts.banner = "Usage: rake export:<object> [options]"
        opts.on("-c", "--collection ARG", Integer) { |num2| options[:collection_id] = num2 }
    end.parse!
    @collection=Collection.find(options[:collection_id])
    puts "--"*20
    puts "[#{@collection.id}] #{@collection.title}"

    return @collection
end


def to_csv(df)
    export = Export.create({ collection_id: @collection.id, title: @collection.title })
    export_item = ExportItem.create({ export_id: export.id, title: @item_title, nrows: df.shape[0], ncolumns: df.shape[1]})

    filename = "kansatsu_#{@collection.title.gsub(/\s+/, "_").underscore}_#{@item_title}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"
    full_path = "#{Rails.root.to_s}/tmp/"
    writer = CSV.open("#{full_path}#{filename}", 'w')
    writer << df.vectors.to_a
    df.each_row do |row|
      writer << row.map { |v| v.to_s.tr(',', '').gsub(/\s+/, " ") }
    end
    writer.close

    export_item.csvfile.attach(io: File.open("#{full_path}#{filename}"), filename: filename);
    puts(df.shape)
    puts "--"*20
    puts "Exported to  #{filename} in #{full_path}"
    puts "--"*20

end




namespace :export do

    task :channels => :environment do
        @collection = params()

        @item_title = 'channels'
        relation = @collection.channels.joins(:pipeline).preload(:pipeline, :channel_stat).left_joins(:channel_stat);

        relation.each do |ch|
            ch.video.sort_by{|v| v.published_at}.last.published_at
        end

        df_channel = Daru::DataFrame.new( relation.map{|record| record.attributes.symbolize_keys} )
        df_pipeline = Daru::DataFrame.new( relation.map{|c| c.pipeline}.map{|record| record.attributes.symbolize_keys} )
        df_stat = Daru::DataFrame.new( relation.filter{|c| c.channel_stat if not c.channel_stat.nil? }.map{|c| c.channel_stat}.map{|record| record.attributes.symbolize_keys} )

        df = df_channel.join(df_stat, how: :outer, on: [:channel_id]);
        df = df.join(df_pipeline, how: :inner, on: [:channel_id]);

        to_csv(df) if df.shape[0] > 0
        exit
    end

    task :videos => :environment do
        @collection = params()

        @item_title = 'videos'
        relation    = @collection.videos.joins(:pipeline, :channel).preload(:pipeline, :channel);
        df_videos   = Daru::DataFrame.new(relation.map{|record| record.attributes.symbolize_keys});
        puts "- df_videos #{df_videos.shape}"
        df_pipeline = Daru::DataFrame.new(relation.map{|c| c.pipeline}.map{|record| record.attributes.symbolize_keys} )
        puts "- df_pipeline #{df_pipeline.shape}"
        df_channel = Daru::DataFrame.new(relation.map{|c| c.channel}.uniq.map{|record| record.attributes.symbolize_keys} )
        puts "- df_channel #{df_channel.shape}"
        puts "- views"

        video_ids = relation.map{|v|v.video_id}.uniq
        videos_count = video_ids.size
        views = Hash.new
        step = 1000
        start = 0
        while start < videos_count + step do
            views = views.merge( VideoStat.where(:video => video_ids[start,start+step]).group(:video_id).maximum(:views));
            start = start + step
            puts "#{start} / #{videos_count}"
        end

        # views       = VideoStat.where(:video => relation.map{|v|v.video_id}.uniq).group(:video_id).maximum(:views)
        puts "- df_stat"
        df_stat     = Daru::DataFrame.new( {:video_id => views.keys, :views => views.values} )
        puts "- df_stat #{df_stat.shape}"
        puts "- joins df_videos.shape #{df_videos.shape} df_stat.shape #{df_stat.shape}"
        df = df_videos.join(df_stat, how: :outer, on: [:video_id]);
        puts "- joins channel  df.shape #{df.shape}"
        df = df.join(df_channel, how: :outer, on: [:channel_id]);
        puts "- joins pipeline df.shape #{df.shape}"
        df = df.join(df_pipeline, how: :inner, on: [:video_id]);
        puts "- to_csv: shape #{df.shape}"
        to_csv(df) if df.shape[0] > 0
        exit
    end

    task :comments => :environment do
        @collection = params()

        @item_title = 'comments'
        puts "- videos"
        videos = @collection.videos.joins(:pipeline).preload(:pipeline)
        puts "- comments"
        relation = Comment.where(:video_id => videos.map{|v|v.video_id}.uniq)
        puts "- df"
        df = Daru::DataFrame.new(relation.map{|record| record.attributes.symbolize_keys} )
        to_csv(df) if df.shape[0] > 0
        exit
    end

    task :captions => :environment do
        @collection = params()

        @item_title = 'captions'
        videos = @collection.videos.joins(:pipeline).preload(:pipeline)
        relation = Caption.where(:video_id => videos.map{|v|v.video_id}.uniq)
        df = Daru::DataFrame.new(relation.map{|record| record.attributes.symbolize_keys})
        to_csv(df) if df.shape[0] > 0
        exit
    end
end
