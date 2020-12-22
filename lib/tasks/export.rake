'''
export = Export.create({ collection_id: @collection.id, title: @collection.title })
'''
require 'tqdm'



namespace :export do

    '''
        export for multiple collections with channels as main object
    '''
    task :nocomments => :environment do
        ActiveRecord::Base.logger.level = 1
        timesig = Time.now.strftime('%Y%m%d_%H%M%S')
        collection_ids = [13,15,20,24]
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
        default_videos = Video.where(:channel_id => channel_ids).where("published_at > '2020-01-01'");

        videos = default_videos.joins(:pipeline).preload(:pipeline);
        puts "-  #{videos.size} videos"
        filename = "kansatsu_videos_#{timesig}.csv"
        CSV.open("#{Rails.root.to_s}/tmp/#{filename}", "wb") do |csv|
          csv << Video.attribute_names + Pipeline.attribute_names
          videos.tqdm.each do |video|
            csv << video.attributes.values + video.pipeline.attributes.values
          end
        end
        puts "videos #{filename}"


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


    task :comments => :environment do
        '''
            Comments
        '''
        ActiveRecord::Base.logger.level = 1
        timesig = Time.now.strftime('%Y%m%d_%H%M%S')
        collection_ids = [13,15,20,24]
        channel_ids = []
        collection_ids.tqdm.each do |cid|
            channel_ids += Collection.find(cid).channels.map{|c| c.channel_id}
        end
        channel_ids = channel_ids.uniq
        default_videos = Video.where(:channel_id => channel_ids)

        number_of_months = 0..11
        number_of_months.to_a.reverse.each do |month_offset|
          start_date = month_offset.months.ago.beginning_of_month
          end_date   = month_offset.months.ago.end_of_month

          date_span = "video.published_at >= '#{start_date}' and video.published_at < '#{end_date}' "
          puts "date_span #{date_span}"

          videos = default_videos.where(date_span).left_joins(:comments).preload(:comments);
          puts "- #{videos.size} comments"

          filename = "kansatsu_comments_#{start_date.strftime("%Y%m%d")}_to_#{end_date.strftime("%Y%m%d")}_#{timesig}.csv"
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


      end # end loop on months


    end


end
