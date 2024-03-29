# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_08_125645) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "User", id: :serial, force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.binary "password"
    t.index ["email"], name: "User_email_key", unique: true
    t.index ["username"], name: "User_username_key", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

# Could not dump table "apikeys" because of following StandardError
#   Unknown type 'apikey_status' for column 'status'

  create_table "augment", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "video_id", limit: 11
    t.tsvector "tsv"
    t.tsvector "tsv_lemma"
    t.datetime "created_at", default: -> { "now()" }
    t.index ["tsv"], name: "augment_tsv_idx", using: :gin
    t.index ["tsv_lemma"], name: "augment_tsv_lemma_idx", using: :gin
    t.index ["video_id"], name: "augment_video_id", unique: true
  end

# Could not dump table "caption" because of following StandardError
#   Unknown type 'caption_status' for column 'status'

  create_table "channel", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "channel_id", limit: 24
    t.string "title"
    t.string "description"
    t.string "country"
    t.string "custom_url"
    t.string "thumbnail"
    t.datetime "created_at"
    t.datetime "retrieved_at"
    t.string "origin"
    t.boolean "has_related", default: false
    t.string "show_related"
    t.float "activity_score", default: 0.0
    t.string "activity", default: "active"
    t.datetime "rss_next_parsing", default: -> { "now()" }
    t.index ["channel_id"], name: "unique_channel_id", unique: true
    t.index ["origin"], name: "channel_origin"
  end

  create_table "channel_stat", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "channel_id", limit: 24, null: false
    t.bigint "views", default: 0
    t.integer "subscribers", default: 0
    t.integer "videos", default: 0
    t.datetime "retrieved_at"
    t.index ["channel_id"], name: "channel_stat_channel_id", unique: true
  end

  create_table "collection_items", force: :cascade do |t|
    t.bigint "collection_id"
    t.string "video_id", limit: 11
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "search_id"
    t.string "channel_id"
    t.string "origin"
    t.index ["channel_id", "collection_id"], name: "index_collection_items_on_channel_id_and_collection_id", unique: true
    t.index ["channel_id"], name: "index_collection_items_on_channel_id"
    t.index ["collection_id"], name: "index_collection_items_on_collection_id"
    t.index ["search_id"], name: "index_collection_items_on_search_id"
    t.index ["video_id", "collection_id"], name: "index_collection_items_on_video_id_and_collection_id", unique: true
  end

  create_table "collections", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string "comment_id"
    t.string "video_id"
    t.string "discussion_id"
    t.string "parent_id"
    t.string "author_name"
    t.string "author_channel_id"
    t.string "text"
    t.integer "reply_count"
    t.integer "like_count"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_comments_on_comment_id", unique: true
    t.index ["discussion_id"], name: "index_comments_on_discussion_id"
    t.index ["video_id"], name: "index_comments_on_video_id"
  end

  create_table "discussions", force: :cascade do |t|
    t.string "video_id"
    t.integer "total_results"
    t.integer "results_per_page"
    t.string "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["video_id"], name: "index_discussions_on_video_id", unique: true
  end

  create_table "exp_related_videos_01", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.integer "source_id"
    t.string "src_channel_id"
    t.string "src_video_id"
    t.string "src_video_title"
    t.integer "position"
    t.string "tgt_channel_id"
    t.string "tgt_channel_title"
    t.boolean "tgt_channel_exists"
    t.string "tgt_video_lang"
    t.string "tgt_video_id"
    t.datetime "tgt_video_published_at"
    t.boolean "tgt_video_exists"
    t.string "tgt_video_title"
    t.datetime "retrieved_at", default: -> { "now()" }
    t.string "processed", default: "new"
    t.date "harvest_date"
  end

  create_table "export_items", force: :cascade do |t|
    t.string "export_id"
    t.string "title"
    t.integer "filesize"
    t.integer "nrows"
    t.integer "ncolumns"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["export_id"], name: "index_export_items_on_export_id"
  end

  create_table "exports", force: :cascade do |t|
    t.string "collection_id"
    t.string "title"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_exports_on_collection_id"
  end

  create_table "flow", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "channel_id", limit: 24
    t.string "video_id", limit: 11
    t.string "flowname", null: false
    t.datetime "start_at"
    t.string "mode", default: "organic"
    t.index ["channel_id", "flowname"], name: "unique_channel_flow", unique: true
    t.index ["video_id", "flowname"], name: "unique_video_flow", unique: true
  end

  create_table "helm", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "jobname", null: false
    t.integer "count_", default: 0, null: false
    t.datetime "created_at", default: -> { "now()" }
    t.index ["jobname"], name: "helm_jobname"
  end

  create_table "origin", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "channel_id", limit: 24
    t.string "origin"
    t.string "filename"
    t.datetime "created_at", default: -> { "now()" }
    t.index ["origin", "channel_id"], name: "origin_channel_id", unique: true
  end

  create_table "pipeline", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "video_id", limit: 11
    t.string "channel_id", limit: 24
    t.string "lang", limit: 10
    t.string "status", default: "incomplete"
    t.datetime "created_at", default: -> { "now()" }
    t.float "lang_conf"
    t.index ["channel_id"], name: "unique_piepline_channel_id", unique: true
    t.index ["video_id"], name: "unique_pipeline_video_id", unique: true
  end

  create_table "plot", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "image_id"
    t.string "location"
    t.string "plottype"
    t.json "plotparams"
    t.string "error"
    t.datetime "generated_at", default: -> { "now()" }, null: false
  end

  create_table "query", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "sql", null: false
    t.string "queryname", null: false
    t.datetime "created_at", default: -> { "now()" }
    t.boolean "active", default: true
    t.index ["queryname"], name: "unique_queryname", unique: true
  end

  create_table "related_channels", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "channel_id"
    t.string "related_id"
    t.datetime "retrieved_at", default: -> { "now()" }
    t.index ["channel_id", "related_id"], name: "unique_related_channel_id", unique: true
  end

  create_table "related_videos_02", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "harvest_date"
    t.string "status"
    t.string "src_channel_id", limit: 24
    t.string "src_video_id", limit: 11
    t.string "src_video_status"
    t.string "tgt_video_id", limit: 11
    t.string "tgt_video_status"
    t.datetime "tgt_video_harvested_at"
    t.string "tgt_channel_id", limit: 24
    t.string "tgt_channel_title"
    t.string "tgt_video_lang"
    t.string "tgt_video_title"
    t.datetime "tgt_video_published_at"
    t.index ["harvest_date"], name: "harvest_date_related_videos_02"
    t.index ["src_channel_id"], name: "channel_related_videos_02"
    t.index ["src_video_id", "harvest_date", "tgt_video_id", "status"], name: "unique_related_videos_02"
    t.index ["src_video_id"], name: "video_related_videos_02"
  end

  create_table "related_videos_export", id: false, force: :cascade do |t|
    t.integer "id", default: -> { "nextval('related_videos_02_id_seq'::regclass)" }, null: false
    t.string "harvest_date"
    t.string "status"
    t.string "src_channel_id", limit: 24
    t.string "src_video_id", limit: 11
    t.string "src_video_status"
    t.string "tgt_video_id", limit: 11
    t.string "tgt_video_status"
    t.datetime "tgt_video_harvested_at"
    t.string "tgt_channel_id", limit: 24
    t.string "tgt_channel_title"
    t.string "tgt_video_lang"
    t.string "tgt_video_title"
    t.datetime "tgt_video_published_at"
    t.index ["harvest_date"], name: "related_videos_export_harvest_date_idx"
    t.index ["src_channel_id"], name: "related_videos_export_src_channel_id_idx"
    t.index ["src_video_id", "harvest_date", "tgt_video_id", "status"], name: "related_videos_export_src_video_id_harvest_date_tgt_video_i_idx"
    t.index ["src_video_id"], name: "related_videos_export_src_video_id_idx"
  end

  create_table "searches", force: :cascade do |t|
    t.json "query"
    t.bigint "collection_id"
    t.string "keywords"
    t.string "on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "behavior", default: "static"
    t.index ["collection_id"], name: "index_searches_on_collection_id"
  end

  create_table "timer", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "video_id", limit: 11
    t.string "channel_id", limit: 24
    t.string "error"
    t.integer "counter", default: 0
    t.datetime "rss_last_parsing"
    t.datetime "rss_next_parsing"
    t.datetime "api_last_request"
    t.datetime "api_next_request"
    t.index ["channel_id"], name: "unique_timer_channel_id", unique: true
    t.index ["video_id"], name: "unique_timer_video_id", unique: true
  end

  create_table "topic", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "channel_id", limit: 24
    t.json "topics"
    t.datetime "created_at", default: -> { "now()" }
    t.index ["channel_id"], name: "topic_channel_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "video", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "video_id", limit: 11
    t.string "channel_id", limit: 24
    t.string "title"
    t.string "summary"
    t.string "thumbnail"
    t.integer "category_id"
    t.string "duration"
    t.string "privacy_status"
    t.boolean "caption", default: false
    t.datetime "published_at"
    t.datetime "retrieved_at"
    t.string "tags"
    t.string "origin"
    t.string "footer"
    t.string "pubdate", limit: 10
    t.string "live_content"
    t.string "default_audio_language"
    t.string "default_language"
    t.integer "seconds"
    t.string "wikitopics"
    t.index ["category_id"], name: "index_video_on_category_id"
    t.index ["channel_id"], name: "idx_video_channel_id"
    t.index ["origin"], name: "video_origin"
    t.index ["published_at"], name: "video_published_at"
    t.index ["video_id"], name: "unique_video_id", unique: true
  end

  create_table "video_recommendations", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "src_video_id", limit: 11
    t.string "tgt_video_id", limit: 11
    t.string "harvest_date"
    t.datetime "tgt_video_harvested_at"
    t.index ["src_video_id", "tgt_video_id", "harvest_date"], name: "unique_vid_recommendation_src_tgt_date_id", unique: true
    t.index ["src_video_id"], name: "src_video_video_recommendations"
    t.index ["tgt_video_id"], name: "tgt_video_video_recommendations"
  end

  create_table "video_scrape", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "video_id", limit: 11
    t.string "completed_date", limit: 10
    t.string "scraped_date", limit: 10
    t.string "scrape_result"
    t.string "downloaded_date", limit: 10
    t.integer "recos_count"
    t.string "captions"
    t.datetime "created_at", default: -> { "now()" }
    t.index ["video_id"], name: "video_scrape_id", unique: true
  end

  create_table "video_stat", id: false, force: :cascade do |t|
    t.integer "id", default: -> { "nextval('video_stat_02_id_seq'::regclass)" }, null: false
    t.string "video_id", limit: 11
    t.string "source", limit: 3, default: "rss"
    t.integer "views", default: 0
    t.string "viewed_at", limit: 10, null: false
    t.integer "like_count"
    t.integer "dislike_count"
    t.integer "favorite_count"
    t.integer "comment_count"
    t.index ["video_id", "viewed_at"], name: "unique_video_stat", unique: true
  end

  create_table "video_stat_01", id: false, force: :cascade do |t|
    t.integer "id", default: -> { "nextval('video_stat_id_seq'::regclass)" }, null: false
    t.string "video_id", null: false
    t.integer "view_count"
    t.string "source", default: "rss"
    t.datetime "retrieved_at"
    t.boolean "eod", default: false
    t.boolean "bod", default: false
  end

  create_table "yt_categories", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.integer "category_id", null: false
    t.string "category", null: false
    t.boolean "assignable"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
