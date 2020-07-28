require 'test_helper'

class VideosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @video = videos(:one)
  end

  test "should get index" do
    get videos_url
    assert_response :success
  end

  test "should get new" do
    get new_video_url
    assert_response :success
  end

  test "should create video" do
    assert_difference('Video.count') do
      post videos_url, params: { video: { caption: @video.caption, category_id: @video.category_id, channel_id: @video.channel_id, default_audio_language: @video.default_audio_language, default_language: @video.default_language, duration: @video.duration, footer: @video.footer, id: @video.id, live_content: @video.live_content, origin: @video.origin, privacy_status: @video.privacy_status, pubdate: @video.pubdate, published_at: @video.published_at, retrieved_at: @video.retrieved_at, seconds: @video.seconds, summary: @video.summary, tags: @video.tags, thumbnail: @video.thumbnail, title: @video.title, video_id: @video.video_id, wikitopics: @video.wikitopics } }
    end

    assert_redirected_to video_url(Video.last)
  end

  test "should show video" do
    get video_url(@video)
    assert_response :success
  end

  test "should get edit" do
    get edit_video_url(@video)
    assert_response :success
  end

  test "should update video" do
    patch video_url(@video), params: { video: { caption: @video.caption, category_id: @video.category_id, channel_id: @video.channel_id, default_audio_language: @video.default_audio_language, default_language: @video.default_language, duration: @video.duration, footer: @video.footer, id: @video.id, live_content: @video.live_content, origin: @video.origin, privacy_status: @video.privacy_status, pubdate: @video.pubdate, published_at: @video.published_at, retrieved_at: @video.retrieved_at, seconds: @video.seconds, summary: @video.summary, tags: @video.tags, thumbnail: @video.thumbnail, title: @video.title, video_id: @video.video_id, wikitopics: @video.wikitopics } }
    assert_redirected_to video_url(@video)
  end

  test "should destroy video" do
    assert_difference('Video.count', -1) do
      delete video_url(@video)
    end

    assert_redirected_to videos_url
  end
end
