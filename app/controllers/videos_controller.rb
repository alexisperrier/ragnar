class VideosController < ApplicationController
    before_action :set_video, only: [:show, :edit, :update, :destroy]
    before_action :set_search,  only: [:index]

    def index
        if params[:search]
            # search by kw
            if @search.keyword and @search.keyword != ''
                puts "==== @search.keyword #{@search.keyword}"
                if @search.keyword.split().size == 1
                    cond = " augment.tsv_lemma @@ to_tsquery('french','#{@search.keyword}') "
                else
                    cond = "(
                            augment.tsv_lemma @@ plainto_tsquery('french','#{@search.keyword}')
                            OR augment.tsv_lemma @@ websearch_to_tsquery('french','#{@search.keyword}')
                            OR augment.tsv_lemma @@ phraseto_tsquery('french','#{@search.keyword}')
                        )"
                end
                query = Video.joins(:augment,:pipeline, :category).where(cond)
            else
                query = Video.joins(:pipeline, :category)
            end

            puts "==== @search.status #{@search.status}"
            if @search.status and @search.status != '--'
                query = query.where(pipeline: {status: @search.status})
            end

            puts "==== @search.category_id #{@search.category_id}"
            if @search.category_id.to_i > 0
                query = query.where(category_id: @search.category_id.to_i)
            end

            puts "==== @search.sort_by #{@search.sort_by} #{@search.sort_asc}"
            if @search.sort_by
                query = query.order("#{@search.sort_by} #{@search.sort_asc}")
            end
        else
            query  = Video.recent.active
        end

        @videos  = query.preload(:pipeline, :channel, :category)

        @videos_count = @videos.count
        puts "-- before pagination"
        @videos  = @videos.page params[:page]
        # puts "-- after pagination video.count #{@videos.count}"
        puts "-- get ids"
        # vids = @videos.map{|v| v.video_id}
        puts "-- get maxviews"
        @maxviews = VideoStat.maxviews(@videos).sort_by {|k, v| -v}.to_h
        puts "-- get upstream"
        @upstream = Recommendation.upstream_counts(@videos)
        puts "-- render"

        @page_title = "YT Videos"

        respond_to do |format|
            format.html
            format.json
        end

  end

  def show
      @views = @video.video_stat.order(:viewed_at).map{|s| [s.viewed_at, s.views]  }.to_h
      upstream = @video.recommendations.group(:src_video_id).count
      @video.upstream_count = Recommendation.where(tgt_video_id: @video.id ).count
      @video.downstream_count = Recommendation.where(src_video_id: @video.id ).count

      @upstream_channel_counts = @video.upstream_channels
      @upstream_channels = Channel.where(channel_id: @upstream_channel_counts.keys())

      @downstream_channel_counts = @video.downstream_channels
      @downstream_channels = Channel.where(channel_id: @downstream_channel_counts.keys())

  end

  def new
    @video = Video.new
  end

  def edit
  end

  def create
    @video = Video.new(video_params)

    respond_to do |format|
      if @video.save
        format.html { redirect_to @video, notice: 'Video was successfully created.' }
        format.json { render :show, status: :created, location: @video }
      else
        format.html { render :new }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @video.update(video_params)
        format.html { redirect_to @video, notice: 'Video was successfully updated.' }
        format.json { render :show, status: :ok, location: @video }
      else
        format.html { render :edit }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @video.destroy
    respond_to do |format|
      format.html { redirect_to videos_url, notice: 'Video was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

   def set_search
        if params[:search]
            @search = VideoSearch.new(params[:search])
        else
            @search = VideoSearch.new({
                status: 'active',
                category_id: 0,
                keyword: nil,
                pubdate: nil,
                sort_by:'published_at',
                sort_asc: 'desc'
            })
        end
  end


    def set_video
      @video = Video.includes(:pipeline,:channel, :caption, :category).find(params[:id])
      @page_title = "YT #{@video.title}"
    end

    # Only allow a list of trusted parameters through.
    def video_params
      params.require(:video).permit(:id, :video_id, :channel_id, :title, :summary, :thumbnail, :category_id, :duration, :privacy_status, :caption, :published_at, :retrieved_at, :tags, :origin, :footer, :pubdate, :live_content, :default_audio_language, :default_language, :seconds, :wikitopics)
    end
end
