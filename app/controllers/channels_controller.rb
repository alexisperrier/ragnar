class ChannelsController < ApplicationController
    before_action :set_channel, only: [:show, :edit, :update]
    before_action :set_search,  only: [:index]

    def new
      @channel = Channel.new
    end

    def create
        if Channel.valid_channel_id(channel_params['channel_id'])
            channel_id = channel_params['channel_id']
        else
            respond_to do |format|
                format.html { redirect_to channels_path, notice: 'This channel_id is not valid'  }
            end
            return
        end
        if Channel.where(:channel_id => channel_id ).size == 0
            @channel = Channel.create(channel_params)
            @pipeline = Pipeline.create({channel_id: @channel.id})
            respond_to do |format|
                format.html { redirect_to @channel, notice: 'The channel was successfully created. It will soon be completed.' }
            end
        else
            @channel = Channel.find(channel_id)
            respond_to do |format|
                format.html { redirect_to channels_path, notice: 'channel already exists'  }
            end
        end
    end

    def index
        if params[:search]
            query = Channel.joins(:pipeline).includes(:channel_stat)
            if @search.status and @search.status != '--'
                query = query.where(pipeline: {status: @search.status})
            end
            puts "==== @search.country #{@search.country}"
            case @search.country
            when "not FR"
                puts "-- country: not FR"
                query = query.where.not(country: ["FR",nil,''])
            when "Null",''
                puts "-- country: [nil,'']"
                query = query.where(country: [nil,''] )
                @search.country = nil
            when 'All'
                puts "-- country: ALL"
                # query = query.where(country: @search.country)
            else
                puts "-- country: #{@search.country}"
                query = query.where(country: @search.country)
            end

            @activity = query.select(:activity).group(:activity).count()
            @activity_score = query.select(:activity_score).group(:activity_score).count()

            if @search.sort_by
                query = query.order("#{@search.sort_by} #{@search.sort_asc}")
            end
            query = query.preload(:pipeline)
        else
            query = Channel.active.order("#{@search.sort_by} #{@search.sort_asc}")
        end

        query = query.preload(:pipeline)

        @channel_count = query.count()
        @channels = query.order(:id).page params[:page]

        # ugly but working
        r = request.fullpath.split('?');
        @export_url_csv =  r.length > 1 ? "exports.csv?object=channels&" + r[1] : "exports.csv?object=channels"
        @page_title = "YT Channels"
        @channel = Channel.new
        respond_to do |format|
            format.html
            format.json
        end
    end

    def show
        # list N most recent videos
        @videos_count = @channel.video.count
        @videos = @channel.video.order(:published_at => 'desc').limit(10)
        # vids = @videos.map{|v| v.video_id}
        @recent_maxviews = VideoStat.maxviews(@videos).sort_by {|k, v| -v}.to_h
        @recent_upstream = Recommendation.upstream_counts(@videos)


        @dailypub = @channel.video.where('published_at > ?', 2.month.ago).order(:pubdate).select(:pubdate).group(:pubdate).count

        @views = @channel.video_stat.select(:video_id).group(:video_id).maximum(:views)
        @views = @views.sort_by {|k, v| -v}.to_h
        if @views.size > 200
            @views = @views.first(200).to_h
        end
        if not @views.empty?
            @avg_views = @views.values.sum() / @views.size
        else
            @avg_views = '--'
        end

        @most_viewed_videos = Video.find(@views.first(5).to_h.keys())
        @mvv_maxviews = VideoStat.maxviews(@most_viewed_videos).sort_by {|k, v| -v}.to_h
        @mvv_upstream = Recommendation.upstream_counts(@most_viewed_videos)

        @downstream_counts  = @channel.downstream
        @downstreams        = Channel.where(channel_id: @downstream_counts.keys())
        @upstream_counts    = @channel.upstream
        @upstreams          = Channel.where(channel_id: @upstream_counts.keys())

    end

    def edit
    end

    def update
        sql = "update pipeline set status = '#{params['channel']['pipeline_attributes']['status']}' where id = '#{params['channel']['pipeline_attributes']['id']}'"
        res = ActiveRecord::Base.connection.execute(sql)

        respond_to do |format|
            if @channel.update(channel_params)
                format.html { redirect_to @channel, notice: 'Channel was successfully updated.' }
                format.json { render :show, status: :ok, location: @channel }
            else
                format.html { render :edit }
                format.json { render json: @channel.errors, status: :unprocessable_entity }
            end
        end
    end

# ----------------------------------------------------------------------
# Private
# ----------------------------------------------------------------------
  private
    def set_channel
        @channel = Channel.includes(:pipeline,:video,:channel_stat).find(params[:id])
        @page_title = "YT #{@channel.title}"
    end

    def set_search
        if params[:search]
            @search = ChannelSearch.new(params[:search])
        else
            @search = ChannelSearch.new({status: 'active', country: 'FR', sort_by:'retrieved_at', sort_asc: 'desc' })
        end
    end

    def channel_params
        # Only allow a list of trusted parameters through.
        params.require(:channel).permit(:title,
            :description, :country, :origin,
            :activity, :rss_next_parsing, :channel_id
            # Uncomment this to update using @channel.update(channel_params)
            # so far not working losing the id field in the sql pipeline_attributes: [:status, :id]
        )
    end

# ----------------------------------------------------------------------
# not used
# ----------------------------------------------------------------------

  '''
  def new
    @channel = Channel.new
  end

  def create
    @channel = Channel.new(channel_params)

    respond_to do |format|
      if @channel.save
        format.html { redirect_to @channel, notice: "Channel was successfully created." }
        format.json { render :show, status: :created, location: @channel }
      else
        format.html { render :new }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /channels/1
  # DELETE /channels/1.json
  def destroy
    @channel.destroy
    respond_to do |format|
      format.html { redirect_to channels_url, notice: "Channel was successfully destroyed."" }
      format.json { head :no_content }
    end
  end
  '''

end
