# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

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
    t.string "channel_id", limit: 24, primary_key: true
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

  create_table "export", id: false, force: :cascade do |t|
    t.serial "id", null: false
    t.string "location", null: false
    t.datetime "generated_at", default: -> { "now()" }
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
    t.serial "id", null: false, primary_key: true
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

end
