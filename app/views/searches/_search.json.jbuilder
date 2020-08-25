json.extract! search, :id, :query, :user_id, :collection_id, :keywords, :on, :created_at, :updated_at
json.url search_url(search, format: :json)
