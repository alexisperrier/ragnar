class SearchController < ApplicationController



  def index
  end

  def channels()
      '''
      available search params:
        - title, description
        - country,
        - activity_score, activity
        - channel_id
      parts: channels
        - then: stats, pipeline status, videos, ...
      returns json
      '''

      exact_query, order_query, contains_query = build_query(params)
      @channels = Channel
      if exact_query.empty? and order_query.empty? and contains_query.empty?
          @channels = @channels.last(10)
      end
      if not exact_query.empty?
          puts exact_query
          @channels = @channels.where(exact_query)
      end

      if not order_query.nil?
          puts order_query
          @channels = @channels.where(order_query)
      end

      if not contains_query.nil?
          puts contains_query
          @channels = @channels.where(contains_query)
      end
      render json: @channels.as_json

  end

  private
  def build_query(params)
      exact_query = {}
      if (params.key?(:country) and params[:country].length <=3 )
          exact_query[:country]     = params[:country]
      end

      if (params.key?(:channel_id) and (params[:channel_id].length == 24) )
        exact_query[:channel_id]  = params[:channel_id]
      end

      if (params.key?(:activity)  )
          exact_query[:activity]    = params[:activity]
      end
      # activity_score is a float
      order_query = nil

      if params.key?(:activity_score)
          order_query = Channel.arel_table[:activity_score].gt(params[:activity_score])
      end

      # title, description contains
      contains_query = nil

      return exact_query, order_query, contains_query
  end

end
