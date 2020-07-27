class ExportsController < ApplicationController
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

            if @search.sort_by
                query = query.order("#{@search.sort_by} #{@search.sort_asc}")
            end
            query = query.preload(:pipeline)
        else
            query = Channel.active.order("#{@search.sort_by} #{@search.sort_asc}")
        end
        @channels = query.preload(:pipeline)

        respond_to do |format|
            format.csv { send_data @channels.to_csv, filename: "channels-#{Date.today}.csv" }
        end
    end
    private
    def set_search
        if params[:search]
            @search = Search.new(params[:search])
        else
            @search = Search.new({status: 'active', country: 'FR', sort_by:'title', sort_asc: 'asc' })
        end
    end


end
