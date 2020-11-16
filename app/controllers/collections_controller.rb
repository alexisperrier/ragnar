class CollectionsController < ApplicationController
  before_action :set_collection, only: [:export, :show, :edit, :update, :destroy]

  def export
      export = Export.create({ collection_id: @collection.id, title: @collection.title })

      # channels

      item_title = 'channels'
      relation = @collection.channels.joins(:pipeline).preload(:pipeline, :channel_stat).left_joins(:channel_stat);


      df_channel = Daru::DataFrame.new(
            relation.map{|record| record.attributes.symbolize_keys}
      )

      df_pipeline = Daru::DataFrame.new(
            relation.map{|c| c.pipeline}.map{|record| record.attributes.symbolize_keys}
      )

      df_stat = Daru::DataFrame.new(
          relation.filter{|c| c.channel_stat if not c.channel_stat.nil? }.map{|c| c.channel_stat}.map{|record| record.attributes.symbolize_keys}
      )

      df = df_channel.join(df_stat, how: :outer, on: [:channel_id]);
      df = df.join(df_pipeline, how: :inner, on: [:channel_id]);

      if df.shape[0] > 0
          export_item = ExportItem.create({ export_id: export.id, title: item_title, nrows: df.shape[0], ncolumns: df.shape[1]})
          filename = "export_#{@collection.title.gsub(/\s+/, "_").underscore}_#{item_title}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"

          tmp_filename = Export.to_csv(df)
          export_item.csvfile.attach(io: File.open(tmp_filename), filename: filename);
      end
      # videos


      item_title = 'videos'
      relation = @collection.videos.joins(:pipeline).preload(:pipeline)


      df_videos = Daru::DataFrame.new(
            relation.map{|record| record.attributes.symbolize_keys}
      )

      df_pipeline = Daru::DataFrame.new(
            relation.map{|c| c.pipeline}.map{|record| record.attributes.symbolize_keys}
      )


      views   = VideoStat.where(:video => relation.map{|v|v.video_id}.uniq).group(:video_id).maximum(:views)
      df_stat = Daru::DataFrame.new(
          {:video_id => views.keys, :views => views.values}
      )


      df = df_videos.join(df_pipeline, how: :inner, on: [:video_id]);
      df = df.join(df_stat, how: :outer, on: [:video_id]);

      if df.shape[0] > 0
          export_item = ExportItem.create({ export_id: export.id, title: item_title, nrows: df.shape[0], ncolumns: df.shape[1]})
          filename    = "export_#{@collection.title.gsub(/\s+/, "_").underscore}_#{item_title}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"

          tmp_filename = Export.to_csv(df)
          export_item.csvfile.attach(io: File.open(tmp_filename), filename: filename);
      end


      # Comments
      item_title = 'comments'

      relation = Comment.where(:video_id => relation.map{|v|v.video_id}.uniq)
      df = Daru::DataFrame.new(
            relation.map{|record| record.attributes.symbolize_keys}
      )

      if df.shape[0] > 0
          export_item = ExportItem.create({ export_id: export.id, title: item_title, nrows: df.shape[0], ncolumns: df.shape[1]})
          filename    = "export_#{@collection.title.gsub(/\s+/, "_").underscore}_#{item_title}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"

          tmp_filename = Export.to_csv(df)
          export_item.csvfile.attach(io: File.open(tmp_filename), filename: filename);
      end


      # Captions
      item_title = 'captions'
      relation = Caption.where(:video_id => relation.map{|v|v.video_id}.uniq)

      df = Daru::DataFrame.new(
            relation.map{|record| record.attributes.symbolize_keys}
      )

      if df.shape[0] > 0
          export_item = ExportItem.create({ export_id: export.id, title: item_title, nrows: df.shape[0], ncolumns: df.shape[1]})
          filename    = "export_#{@collection.title.gsub(/\s+/, "_").underscore}_#{item_title}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"

          tmp_filename = Export.to_csv(df)
          export_item.csvfile.attach(io: File.open(tmp_filename), filename: filename);
      end
      redirect_to collection_path(@collection), notice: "Data exported for channels, videos, comments and captions"

  end

  def index
    @collections = current_user.collections.all

    @page_title = "Collections"
  end

  # GET /collections/1
  # GET /collections/1.json
  def show
      @page_title = @collection.title
      @channels = @collection.channels.preload(:collection_items, :pipeline).joins(:collection_items, :pipeline).order("title asc").limit(100)
      query = @collection.videos.joins(:channel, :pipeline).left_joins(:collection_items => :search).order("channel.title asc").page params[:page]
      @videos = query.preload(:channel, :pipeline, :collection_items => :search)
      # @exports = @collection.exports.map{|export| export.export_items }
      # @exports = @collection.exports
      @last_export = @collection.exports.last
  end

  # GET /collections/new
  def new
    @collection = Collection.new
    # @confirmation = false
  end

  # GET /collections/1/edit
  def edit
  end

  def validate

      @collection = Collection.new(collection_params)
      @csvfilename = ActiveStorage::Blob.service.send(:path_for, @collection.csvfile.key)

      @messages, @warnings, @errors = Collection.validate_upload(@csvfilename)

      render :confirmation
  end

  def create

    @collection = Collection.new(collection_params)
    @collection.user = current_user
    @collection.save

    channel_ids, video_ids = Collection.extract_items(params['csvfilename'])

    # Create new channels

    if not channel_ids.empty?
        existing_channel_ids = Channel.select("channel_id").where(:channel_id => channel_ids).map{|c| c.channel_id}
        if existing_channel_ids.size < channel_ids.size
            new_channel_ids = channel_ids - existing_channel_ids
            new_channel_ids.each do |channel_id|
                Channel.create({channel_id: channel_id, origin: @collection.title})
                Pipeline.create({channel_id: channel_id, status: :incomplete})
            end
        end
        # create collection items
        channel_ids.each do |channel_id|
            CollectionItem.create({channel_id: channel_id, origin: @collection.title, collection_id: @collection.id})
        end
    end

    # create new videos
    if not video_ids.empty?
        existing_video_ids = Video.select("video_id").where(:video_id => video_ids).map{|c| c.video_id}
        if existing_video_ids.size < video_ids.size
            new_video_ids = video_ids - existing_video_ids
            new_video_ids.each do |video_id|
                Video.create({video_id: video_id, origin: @collection.title})
                Pipeline.create({video_id: video_id, status: :incomplete})
            end
        end
        # create collection items
        video_ids.each do |video_id|
            CollectionItem.create({video_id: video_id, origin: @collection.title, collection_id: @collection.id})
        end

    end


    respond_to do |format|
      if @collection.save
        format.html { redirect_to @collection, notice: 'Collection was successfully created.' }
        format.json { render :show, status: :created, location: @collection }
      else
        format.html { render :new }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collections/1
  # PATCH/PUT /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to @collection, notice: 'Collection was successfully updated.' }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.json
  def destroy
    @collection.destroy
    respond_to do |format|
      format.html { redirect_to collections_url, notice: 'Collection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def collection_params
      params.require(:collection).permit(:title, :description, :csvfile,:csvfilename)
    end
end
