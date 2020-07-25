class ChannelsController < ApplicationController
    before_action :set_channel, only: [:show, :edit, :update]
    before_action :set_search,  only: [:index]

    def index
        if params[:search]
            query = Channel.joins(:pipeline).includes(:channel_stat)
            if @search.status
                query = query.where(pipeline: {status: @search.status})
            end
            if @search.country and @search.country != '--'
                query = query.where(country: @search.country)
            end
            query = query.preload(:pipeline)
        else
            query = Channel.active
        end

        @channels = query.preload(:pipeline).order(:id).page params[:page]

        respond_to do |format|
            format.html
            format.json
        end
    end

    def show
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
        @channel = Channel.includes(:pipeline,:channel_stat).find(params[:id])
    end

    def set_search
        if params[:search]
            @search = Search.new(params[:search])
        else
            @search = Search.new({status: 'active', country: 'DK' })
        end
        puts "--"*20
        puts "search: "
        puts @search.inspect
        puts "--"*20
    end

    def channel_params
        # Only allow a list of trusted parameters through.
        params.require(:channel).permit(:title,
            :description, :country, :origin,
            :activity, :rss_next_parsing,
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
