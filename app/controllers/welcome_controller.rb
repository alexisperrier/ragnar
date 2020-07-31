class WelcomeController < ApplicationController
    def index

        @mvv  = Video.most_viewed
        # vids = @mvv.map{|v| v.video_id}
        @mvv_upstream = Recommendation.upstream_counts(@mvv)
        @mvv_maxviews = VideoStat.maxviews(@mvv).sort_by {|k, v| -v}.to_h
        @mvv = @mvv.where_with_order(:video_id, @mvv_maxviews.keys() )

        @mrecv_upstream = Recommendation.most_recommended
        vids    = @mrecv_upstream.keys()
        @mrecv  = Video.where_with_order(:video_id, vids).preload(:pipeline, :channel, :category)
        @mrecv_maxviews = VideoStat.maxviews(vids)

        respond_to do |format|
            format.html
            format.json
        end

    end
end
