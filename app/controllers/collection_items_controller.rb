class CollectionItemsController < ApplicationController

    def addchannel
        channel_id = params["channel_id"].to_s[0..23]
        if channel_id.length !=24
            redirect_to channels_path, notice: "This channel_id is not valid"
            return
        end
        if Channel.find(channel_id).nil?
            redirect_to channels_path, notice: "This channel does not exist"
            return
        end


        sql = " insert into collection_items
            (channel_id, collection_id, origin, created_at, updated_at)
            values
            ('#{channel_id}',#{params['collection_id']}, '#{params['origin']}', now(), now())
            on conflict (channel_id,collection_id) DO NOTHING; "

        results = ActiveRecord::Base.connection.execute(sql)

        redirect_to channel_path(channel_id), notice: "The channel was added to the collection"

    end

    def addvideos
        if (params['collection_id'] == 0)
            redirect_to videos_path + "?" + params["search_params"]
            return
        end
        search_params = Rack::Utils.parse_query(params['search_params'])
        search_params = search_params.filter{|k,v| k[0..5] == 'search'   }.map{|k,v| [k[7..-2],v]  }.to_h
        @search = VideoSearch.new(search_params)

        query = Video.select(:video_id)
        if @search.status and @search.status != '--'
            query = query.joins(:pipeline).where(pipeline: {status: @search.status})
        end
        if @search.category_id.to_i > 0
            query = query.joins(:category).where(category_id: @search.category_id.to_i)
        end

        if @search.keyword and @search.keyword != ''
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


        video_ids = query.map{|q| q.video_id}

        # -- save search
        src = Search.create({
                query: search_params,
                collection_id: params['collection_id'],
                keywords: @search.keyword,
                on: 'videos'
            })


        # -- add search_id to collection_items
        insert_sql = " insert into collection_items (video_id, collection_id, search_id, origin, created_at, updated_at)  values "
        video_ids.each do |video_id|
            sql = insert_sql + " ('#{video_id}',#{params['collection_id']}, #{src.id}, '#{params['origin']}', now(), now())  on conflict (video_id,collection_id) DO NOTHING; "
            results = ActiveRecord::Base.connection.execute(sql)
        end
        redirect_to videos_path + "?" + params["search_params"], notice: "#{video_ids.size} videos added to collection"
    end

    def index
    end

    def edit
    end
end
