require "application_system_test_case"

class VideosTest < ApplicationSystemTestCase
  setup do
    @video = videos(:one)
  end

  test "visiting the index" do
    visit videos_url
    assert_selector "h1", text: "Videos"
  end

  test "creating a Video" do
    visit videos_url
    click_on "New Video"

    check "Caption" if @video.caption
    fill_in "Category", with: @video.category_id
    fill_in "Channel", with: @video.channel_id
    fill_in "Default audio language", with: @video.default_audio_language
    fill_in "Default language", with: @video.default_language
    fill_in "Duration", with: @video.duration
    fill_in "Footer", with: @video.footer
    fill_in "Id", with: @video.id
    fill_in "Live content", with: @video.live_content
    fill_in "Origin", with: @video.origin
    fill_in "Privacy status", with: @video.privacy_status
    fill_in "Pubdate", with: @video.pubdate
    fill_in "Published at", with: @video.published_at
    fill_in "Retrieved at", with: @video.retrieved_at
    fill_in "Seconds", with: @video.seconds
    fill_in "Summary", with: @video.summary
    fill_in "Tags", with: @video.tags
    fill_in "Thumbnail", with: @video.thumbnail
    fill_in "Title", with: @video.title
    fill_in "Video", with: @video.video_id
    fill_in "Wikitopics", with: @video.wikitopics
    click_on "Create Video"

    assert_text "Video was successfully created"
    click_on "Back"
  end

  test "updating a Video" do
    visit videos_url
    click_on "Edit", match: :first

    check "Caption" if @video.caption
    fill_in "Category", with: @video.category_id
    fill_in "Channel", with: @video.channel_id
    fill_in "Default audio language", with: @video.default_audio_language
    fill_in "Default language", with: @video.default_language
    fill_in "Duration", with: @video.duration
    fill_in "Footer", with: @video.footer
    fill_in "Id", with: @video.id
    fill_in "Live content", with: @video.live_content
    fill_in "Origin", with: @video.origin
    fill_in "Privacy status", with: @video.privacy_status
    fill_in "Pubdate", with: @video.pubdate
    fill_in "Published at", with: @video.published_at
    fill_in "Retrieved at", with: @video.retrieved_at
    fill_in "Seconds", with: @video.seconds
    fill_in "Summary", with: @video.summary
    fill_in "Tags", with: @video.tags
    fill_in "Thumbnail", with: @video.thumbnail
    fill_in "Title", with: @video.title
    fill_in "Video", with: @video.video_id
    fill_in "Wikitopics", with: @video.wikitopics
    click_on "Update Video"

    assert_text "Video was successfully updated"
    click_on "Back"
  end

  test "destroying a Video" do
    visit videos_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Video was successfully destroyed"
  end
end
