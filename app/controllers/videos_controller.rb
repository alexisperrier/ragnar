class VideosController < ApplicationController
  before_action :set_video, only: [:show, :edit, :update, :destroy]

  def index
    @recent_videos  = Video.recent.active
    @recent_videos_count = @recent_videos.count
    @recent_videos  = @recent_videos.order(:published_at => 'desc').page params[:page]

    # @most_viewed_video_ids  = VideoStat.where("viewed_at > ?", 1.day.ago).order(:views => 'desc').select(:video_id).limit(20).map{ |v| v.video_id }


    respond_to do |format|
        format.html
        format.json
    end

  end

  def show
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
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      @video = Video.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def video_params
      params.require(:video).permit(:id, :video_id, :channel_id, :title, :summary, :thumbnail, :category_id, :duration, :privacy_status, :caption, :published_at, :retrieved_at, :tags, :origin, :footer, :pubdate, :live_content, :default_audio_language, :default_language, :seconds, :wikitopics)
    end
end
