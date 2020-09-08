class VideosController < ApplicationController
    before_action :set_video, only: [:show, :edit, :update, :destroy]
    before_action :set_search,  only: [:index]

    def index
        if params[:search]
            # search by kw
            query = Video
            puts "==== @search.status #{@search.status}"
            if @search.status and @search.status != '--'
                query = query.joins(:pipeline).where(pipeline: {status: @search.status})
            end
            puts "==== @search.category_id #{@search.category_id}"
            if @search.category_id.to_i > 0
                query = query.where(category_id: @search.category_id.to_i)
            end

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
                query = query.joins(:augment).where(cond)
            end

            if @search.sort_by and @search.sort_by != '--'
                query = query.order("#{@search.sort_by} #{@search.sort_asc}")
            end
        else
            query  = Video.recent.active
        end

        @videos_count   = query.count
        query           = query.page params[:page]
        @videos         = query.preload(:pipeline, :channel, :category)
        @page_title     = "YT Videos"
        @video          = Video.new

        respond_to do |format|
            format.html
            format.json
        end

  end

  def show
      @video_stats = VideoStat.where(video_id:  @video.video_id).order(:viewed_at => 'desc')
      if @video_stats.count > 1
          @views = @video_stats.map{|s| [s.viewed_at, s.views]  }.to_h
      end

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

      if Video.valid_video_id(video_params['video_id'])
          video_id = video_params['video_id']
      else
          respond_to do |format|
              format.html { redirect_to videos_path, notice: 'This video_id is not valid'  }
          end
          return
      end

      if Video.where(:video_id => video_id ).size == 0
          @video = Video.create(video_params)
          @pipeline = Pipeline.create({video_id: @video.id})
          respond_to do |format|
              format.html { redirect_to @video, notice: 'video was successfully created.' }
          end
      else
          @video = Video.find(video_id).nil?
          respond_to do |format|
              format.html { redirect_to videos_path, notice: 'video already exists'  }
          end
      end
  end

  def update
    respond_to do |format|
      if @video.update(video_params)
        format.html { redirect_to @video, notice: 'Video was successfully updated.' }
      else
        format.html { render :edit }
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
                sort_by:'--',
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
