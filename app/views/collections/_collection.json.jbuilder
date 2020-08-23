json.extract! collection, :id, :title, :description, :user_id, :created_at, :updated_at
json.url collection_url(collection, format: :json)
