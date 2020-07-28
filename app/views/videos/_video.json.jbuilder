json.extract! video, :id, :id, :video_id, :channel_id, :title, :summary, :thumbnail, :category_id, :duration, :privacy_status, :caption, :published_at, :retrieved_at, :tags, :origin, :footer, :pubdate, :live_content, :default_audio_language, :default_language, :seconds, :wikitopics, :created_at, :updated_at
json.url video_url(video, format: :json)
