'''
Returns a report with counts of videos, channels, ...
'''
require 'tqdm'

namespace :report do

    task :stats => :environment do
        video_count = Video.count
        video_stats_count = VideoStat.count
        channel_count = Channel.count
        channel_stats_count = Channel.count
        comments_count = Comment.count
        captions_count = Caption.count
        reco_video_count = Recommendation.count
        reco_channel_count = RelatedChannel.count
        puts "--"
        puts "\t#{video_count} videos"
        puts "\t#{channel_count} channels"
        puts "-- Stats"
        puts "\t#{video_stats_count} videos stats"
        puts "\t#{channel_stats_count} channels stats"
        puts "-- Comments & Captions"
        puts "\t#{comments_count} comments"
        puts "\t#{captions_count} captions"
        puts "-- Recommendations"
        puts "\t#{reco_video_count} video recommendations"
        puts "\t#{reco_channel_count} channel recommendations"
        exit
    end
end
