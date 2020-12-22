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

    '''
        export for multiple collections with channels as main object
    '''
    task :all => :environment do
        ActiveRecord::Base.logger.level = 1
        since = '2020-12-01'
        timesig = Time.now.strftime('%Y%m%d_%H%M%S')
        # collection_ids = [13,15,20,24]
        collection_ids = [13]
        # channel ids
        channel_ids = []
        collection_ids.tqdm.each do |cid|
            channel_ids += Collection.find(cid).channels.map{|c| c.channel_id}
        end
        channel_ids = channel_ids.uniq
        puts "-- #{channel_ids.size} channels";
        '''
            Channels
        '''
        channels = Channel.where(:channel_id => channel_ids).joins(:pipeline).preload(:pipeline, :channel_stat).left_joins(:channel_stat);

        filename = "kansatsu_channels_#{timesig}.csv"
        CSV.open("#{Rails.root.to_s}/tmp/#{filename}", "wb") do |csv|
          csv << Channel.attribute_names + Pipeline.attribute_names;
          channels.tqdm.each do |channel|
            csv << channel.attributes.values + channel.pipeline.attributes.values;
          end;
        end;
        puts "channels #{filename}"

        filename = "kansatsu_channels_stats_#{timesig}.csv"
        CSV.open("#{Rails.root.to_s}/tmp/#{filename}", "wb") do |csv|
          csv << ChannelStat.attribute_names;
          channels.tqdm.map{|c| c.channel_stat}.each do |channel_stat|
              unless channel_stat.nil?
                  csv << channel_stat.attributes.values
              end;
          end;
        end;
        puts "channels stats #{filename}"

        '''
            Videos
        '''
        default_videos = Video.where(:channel_id => channel_ids).where("video.published_at > '#{since}'");
        puts "-  #{default_videos.size} videos"

        videos = default_videos.joins(:pipeline).preload(:pipeline);
        filename = "kansatsu_videos_#{timesig}.csv"
        CSV.open("#{Rails.root.to_s}/tmp/#{filename}", "wb") do |csv|
          csv << Video.attribute_names + Pipeline.attribute_names
          videos.tqdm.each do |video|
            csv << video.attributes.values + video.pipeline.attributes.values
          end
        end
        puts "videos #{filename}"

        '''
            Comments
        '''
        videos = default_videos.left_joins(:comments).preload(:comments);
        puts "- #{videos.size} comments"
        filename = "kansatsu_comments_#{timesig}.csv"
        k = 0
        CSV.open("#{Rails.root.to_s}/tmp/#{filename}", "wb") do |csv|
          csv << Comment.attribute_names;
          videos.tqdm.each do |video|
              unless video.comments.blank?
                  k +=1
                  if k % 5000 == 0
                      puts "[#{k}] / #{video.comments.size} comments"
                  end
                  video.comments.each do |comment|
                      csv << comment.attributes.values
                  end
              end
          end
        end
        puts "comments #{filename}"


        '''
            Captions
        '''
        videos = default_videos.left_joins(:caption).preload(:caption);
        puts "-  #{videos.size} captions"
        filename = "kansatsu_captions_#{timesig}.csv"
        CSV.open("#{Rails.root.to_s}/tmp/#{filename}", "wb") do |csv|
            csv << Caption.attribute_names;
            videos.tqdm.each do |video|
                unless video.caption.nil?
                    csv << video.caption.attributes.values
                end
            end
        end
        puts "captions #{filename}"

        '''
            Videos stats views
        '''
        ActiveRecord::Base.logger.level = 1
        puts "video stats"
        video_ids = default_videos.map{|v| v.video_id}

        videos_count = video_ids.size
        views = Hash.new
        step = 200
        start = 0
        k = 0
        while start < videos_count + step do
            max_views = VideoStat.where(:video =>video_ids[start..start+step-1] ).group(:video_id).maximum(:views); ''
            views = views.merge(max_views); ''
            start = start + step; ''
            k +=1
            if k % 100 == 0
                puts "[#{k}] #{start} / #{videos_count}"
            end
        end

        filename = "kansatsu_videos_stats_#{timesig}.csv"
        CSV.open("#{Rails.root.to_s}/tmp/#{filename}", "wb") do |csv|
          csv << ['video_id','views']
          views.keys.each do |video_id|
              csv << [video_id, views[video_id]]
          end
        end
        puts "videos stats #{filename}"

    end

    task :channels => :environment do
        @collection = params()

        @item_title = 'channels'
        relation = @collection.channels.joins(:pipeline).preload(:pipeline, :channel_stat).left_joins(:channel_stat);

        df_channel = Daru::DataFrame.new( relation.map{|record| record.attributes.symbolize_keys} )
        df_pipeline = Daru::DataFrame.new( relation.map{|c| c.pipeline}.map{|record| record.attributes.symbolize_keys} )
        df_stat = Daru::DataFrame.new( relation.filter{|c| c.channel_stat if not c.channel_stat.nil? }.map{|c| c.channel_stat}.map{|record| record.attributes.symbolize_keys} )

        df = df_channel.join(df_stat, how: :outer, on: [:channel_id]);
        df = df.join(df_pipeline, how: :inner, on: [:channel_id]);

        to_csv(df) if df.shape[0] > 0
        exit
    end

    task :videos => :environment do
        @item_title = 'videos'
        @collection = params()
        channel_ids = @collection.channels.map{|c| c.channel_id}.uniq
        videos = Video.where(:channel_id => channel_ids).joins(:pipeline, :channel).preload(:pipeline, :channel);
        # relation    = @collection.videos.joins(:pipeline, :channel).preload(:pipeline, :channel);
        puts "-  #{videos.size} videos "

        df_videos   = Daru::DataFrame.new(videos.map{|record| record.attributes.symbolize_keys});
        puts "- df_videos #{df_videos.shape}"
        df_pipeline = Daru::DataFrame.new(videos.map{|c| c.pipeline}.map{|record| record.attributes.symbolize_keys} )
        puts "- df_pipeline #{df_pipeline.shape}"
        df_channel  = Daru::DataFrame.new(videos.map{|c| c.channel}.uniq.map{|record| record.attributes.symbolize_keys} )
        puts "- df_channel #{df_channel.shape}"
        puts "- views"

        video_ids = videos.map{|v|v.video_id}.uniq
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
        channel_ids = @collection.channels.map{|c| c.channel_id}.uniq
        videos = Video.where(:channel_id => channel_ids).joins(:pipeline).preload(:pipeline);
        # videos = @collection.videos.joins(:pipeline).preload(:pipeline)
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
        channel_ids = @collection.channels.map{|c| c.channel_id}.uniq
        videos = Video.where(:channel_id => channel_ids).joins(:pipeline).preload(:pipeline);
        # videos = @collection.videos.joins(:pipeline).preload(:pipeline)
        relation = Caption.where(:video_id => videos.map{|v|v.video_id}.uniq)
        df = Daru::DataFrame.new(relation.map{|record| record.attributes.symbolize_keys})
        to_csv(df) if df.shape[0] > 0
        exit
    end
end
