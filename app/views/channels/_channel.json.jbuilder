json.extract! channel, :id, :id, :channel_id, :title, :description, :country, :custom_url, :thumbnail, :retrieved_at, :origin, :has_related, :show_related, :activity_score, :activity, :rss_next_parsing, :created_at
json.url channel_url(channel, format: :json)
